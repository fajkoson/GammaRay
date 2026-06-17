# This file is part of GammaRay, the Qt application inspection and manipulation tool.
#
# SPDX-FileCopyrightText: 2012 Klarälvdalens Datakonsult AB, a KDAB Group company <info@kdab.com>
#
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Contact KDAB at <info@kdab.com> for commercial licensing options.
#

# shared part
set(gammaray_statemachineviewer_shared_srcs statemachineviewerinterface.cpp)

# probe part
if(NOT GAMMARAY_CLIENT_ONLY_BUILD)
    set(gammaray_statemachineviewer_plugin_srcs
        qsmstatemachinedebuginterface.cpp
        qsmstatemachinedebuginterface.h
        statemachinedebuginterface.cpp
        statemachinedebuginterface.h
        statemachineviewerserver.cpp
        statemachineviewerserver.h
        statemachinewatcher.cpp
        statemachinewatcher.h
        statemodel.cpp
        statemodel.h
        transitionmodel.cpp
        transitionmodel.h
    )

    if(TARGET Qt::Scxml)
        list(APPEND gammaray_statemachineviewer_plugin_srcs qscxmlstatemachinedebuginterface.cpp
             qscxmlstatemachinedebuginterface.h
        )
    endif()

    gammaray_add_plugin(
        gammaray_statemachineviewer_plugin
        JSON
        gammaray_statemachineviewer.json
        SOURCES
        ${gammaray_statemachineviewer_plugin_srcs}
        ${gammaray_statemachineviewer_shared_srcs}
    )

    set_target_properties(gammaray_statemachineviewer_plugin PROPERTIES DISABLE_PRECOMPILE_HEADERS ON)

    target_link_libraries(gammaray_statemachineviewer_plugin gammaray_core)

    if(TARGET Qt::Scxml)
        target_link_libraries(gammaray_statemachineviewer_plugin Qt::Scxml)
        if(TARGET Qt6::ScxmlPrivate)
            target_link_libraries(gammaray_statemachineviewer_plugin Qt6::ScxmlPrivate)
        elseif(TARGET Qt::ScxmlPrivate)
            target_link_libraries(gammaray_statemachineviewer_plugin Qt::ScxmlPrivate)
        elseif(QT_VERSION_MAJOR EQUAL 6 AND TARGET Qt6::Scxml)
            get_target_property(_gammaray_scxml_version Qt6::Scxml _qt_package_version)
            get_target_property(_gammaray_scxml_include_name Qt6::Scxml _qt_module_include_name)
            if(NOT _gammaray_scxml_version OR _gammaray_scxml_version MATCHES "-NOTFOUND$")
                set(_gammaray_scxml_version ${Qt6Scxml_VERSION})
            endif()
            if(NOT _gammaray_scxml_version)
                set(_gammaray_scxml_version ${Qt6_VERSION})
            endif()
            if(NOT _gammaray_scxml_include_name OR _gammaray_scxml_include_name MATCHES "-NOTFOUND$")
                set(_gammaray_scxml_include_name QtScxml)
            endif()
            if(QT6_INSTALL_PREFIX AND _gammaray_scxml_version AND _gammaray_scxml_include_name)
                target_include_directories(
                    gammaray_statemachineviewer_plugin
                    PRIVATE
                        "${QT6_INSTALL_PREFIX}/include/QtCore/${_gammaray_scxml_version}"
                        "${QT6_INSTALL_PREFIX}/include/${_gammaray_scxml_include_name}/${_gammaray_scxml_version}/${_gammaray_scxml_include_name}"
                )
            endif()
        endif()
    endif()
    if(TARGET Qt6::StateMachine)
        target_link_libraries(gammaray_statemachineviewer_plugin Qt6::StateMachine)
        if(TARGET Qt6::StateMachinePrivate)
            target_link_libraries(gammaray_statemachineviewer_plugin Qt6::StateMachinePrivate)
        endif()
    endif()
endif()

# UI part
if(GAMMARAY_BUILD_UI AND GAMMARAY_WITH_KDSME)

    set(gammaray_statemachineviewer_ui_plugin_srcs
        statemachineviewerclient.cpp
        statemachineviewerclient.h
        statemachineviewerwidget.cpp
        statemachineviewerwidget.h
        statemodeldelegate.cpp
        statemodeldelegate.h
    )

    gammaray_add_plugin(
        gammaray_statemachineviewer_ui_plugin
        JSON
        gammaray_statemachineviewer.json
        SOURCES
        ${gammaray_statemachineviewer_ui_plugin_srcs}
        ${gammaray_statemachineviewer_shared_srcs}
    )

    target_link_libraries(
        gammaray_statemachineviewer_ui_plugin
        KDSME::Core
        KDSME::View
        gammaray_common
        gammaray_ui
    )

    if(${QT_VERSION_MAJOR} EQUAL 6 AND TARGET Qt6::StateMachine)
        target_link_libraries(gammaray_statemachineviewer_ui_plugin Qt6::StateMachine)
    endif()
endif()
