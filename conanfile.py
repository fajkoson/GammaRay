import os

from conan import ConanFile
from conan.tools.cmake import CMake, CMakeDeps, CMakeToolchain, cmake_layout

required_conan_version = ">=2.12.1"

class Essence(ConanFile):
    settings = "os", "arch", "compiler", "build_type"
 
    default_options = {
        "gtest/*:shared": False,
        "jasper/*:shared": False,
        "jasper/*:with_libjpeg": False,
        "json-schema-validator/*:shared": False,
        "onnxruntime/*:minimal": False,
        "onnxruntime/*:shared": True,
        "onnxruntime/*:with_cuda": True,
        "opencv/*:opencv_dnn": False,
        "opencv/*:opencv_world": True,
        "opencv/*:shared": True,
    }
    
    def build_requirements(self):
        self.tool_requires("winflexbison/2.5.25@tescan/stable#010a2aee9889ea422d1f07b66c062155")

    def requirements(self):
        self.requires("zlib/1.3.1@tescan/stable#0b2a8ddfcf314d756debd178e254127f")
        self.requires("eigen/3.4.0@tescan/stable#17ed355a1e696f4704bca08a6a26c965")
        self.requires("gtest/1.17.0@tescan/stable#9f0b8539fffbdd907220d012f31af146")
        self.requires("json-schema-validator/2.3.0@tescan/stable#04511b0233eb4097f4251bc7d699e751")
        self.requires("nlohmann_json/3.11.3@tescan/stable#241d3fdb132ea875d713681e64e05646")
        #self.requires("onnxruntime/1.22.0@tescan/stable#91348e45bdc1abb5f73f151f63bd6ada")
        #self.requires("opencv/4.13.0@tescan/stable#72832130cb265c619b3ee7ad1b161a92")
        self.requires("qt/6.10.3@tescan/stable#9d1da568146340cedc81a50ab600dc94")
        #self.requires("benchmark/1.8.0@tescan/stable#17a85956351c4cddcfcfc718c4ff8640")
        #self.requires("cudatoolkit/12.6.3@tescan/stable#be888507e0cd2fe3c7cc25cc384eb54c")
        #self.requires("cudnn/9.6.0.74@tescan/stable#10b959f08cb8d9a29d336062451a8645")
        #self.requires("jasper/4.2.0@tescan/stable#356cb73baf6e14e5f5153009c3a3210c")

        # qt and libcurl share crossdependency openssl
        self.requires("libcurl/8.5.0@tescan/stable#ede0f217106d3a83a644cc06f0231919")
        self.requires("hdf5/1.14.5@tescan/stable#f36762f40dc51b1ba91cc75aa4813417")

        # IMPORTANT: 
        # force the sqlite version used transitively by Qt 6.10.0
        # so the graph always matches the already-built Qt binaries.
        #self.requires("sqlite3/3.47.2@tescan/stable", override=True)
        self.requires("sqlite3/3.51.0@tescan/stable", override=True)
        # OpenSSL is used directly, so do NOT mark it as override
        self.requires("openssl/3.6.0@tescan/stable#be93d9109d9d423af3438feefa594681")   

    def layout(self):
        """Defines the folder structure for builds and where to place CMake
        files containing information about where to find dependencies.

        The created build folders are named according to the platform
        architecture and build type.
        """
        arch = "x64" if str(self.settings.arch) == "x86_64" else self.settings.arch
        conf = "{}-{}".format(arch, self.settings.build_type).lower()
        self.folders.build = os.path.join("build", conf)
        self.folders.generators = os.path.join("conan", conf)
        self.folders.source = "."

    def generate(self):
        """Generates the CMake toolchain file and CMake files for dependency
        resolution.

        The default behaviour is customized in order to work with MSVC 2019. We
        are using Ninja and our own CMakePreset file. In addition, we are using
        an additional CMake toolchain file defining the default warning flags
        for MSVC.
        """

        # NOTE: For this to work, we first need to edit the conan configuration
        # options before manually generating the CMakeToolchain and CMakeDeps.
        # NOTE: There is a second approach to this approach which will create
        # more composable and reusable package structure. It lies in creating a
        # special toolchain conan package containing only the user toolchain and
        # defining the specific config options in its package_info(self) method.
        msvc_toolchain = os.path.join(self.source_folder, "g4base", "cmake", "msvc_toolchain.cmake")
        self.conf.append("tools.cmake.cmaketoolchain:user_toolchain", msvc_toolchain)

        toolchain = CMakeToolchain(self, "Ninja")
        toolchain.user_presets_path = False
        toolchain.generate()

        deps = CMakeDeps(self)
        deps.generate()

    def build(self):
        """Build the package.

        Takes the generated CMakeUserPreset.json file from the generate(self)
        method, calls cmake --preset <build_type> and cmake --build --preset
        <build_type>.
        """
        cmake = CMake(self)
        cmake.configure()
        cmake.build()
