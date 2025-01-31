// Copyright (c) 2016 Ultimaker B.V.
// Cura is released under the terms of the AGPLv3 or higher.

import QtQuick 2.1
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.1

import UM 1.1 as UM

UM.PreferencesPage
{
    //: General configuration page title
    title: catalog.i18nc("@title:tab","General")

    function setDefaultLanguage(languageCode)
    {
        //loops trough the languageList and sets the language using the languageCode
        for(var i = 0; i < languageList.count; i++)
        {
            if (languageComboBox.model.get(i).code == languageCode)
            {
                languageComboBox.currentIndex = i
            }
        }
    }

    function setDefaultDiscardOrKeepProfile(code)
    {
        for (var i = 0; i < choiceOnProfileOverrideDropDownButton.model.count; i++)
        {
            if (choiceOnProfileOverrideDropDownButton.model.get(i).code == code)
            {
                choiceOnProfileOverrideDropDownButton.currentIndex = i;
                break;
            }
        }
    }

    function reset()
    {
        UM.Preferences.resetPreference("general/language")
        var defaultLanguage = UM.Preferences.getValue("general/language")
        setDefaultLanguage(defaultLanguage)

        UM.Preferences.resetPreference("physics/automatic_push_free")
        pushFreeCheckbox.checked = boolCheck(UM.Preferences.getValue("physics/automatic_push_free"))
        UM.Preferences.resetPreference("physics/automatic_drop_down")
        dropDownCheckbox.checked = boolCheck(UM.Preferences.getValue("physics/automatic_drop_down"))
        UM.Preferences.resetPreference("mesh/scale_to_fit")
        scaleToFitCheckbox.checked = boolCheck(UM.Preferences.getValue("mesh/scale_to_fit"))
        UM.Preferences.resetPreference("mesh/scale_tiny_meshes")
        scaleTinyCheckbox.checked = boolCheck(UM.Preferences.getValue("mesh/scale_tiny_meshes"))
        UM.Preferences.resetPreference("cura/jobname_prefix")
        prefixJobNameCheckbox.checked = boolCheck(UM.Preferences.getValue("cura/jobname_prefix"))
        UM.Preferences.resetPreference("view/show_overhang");
        showOverhangCheckbox.checked = boolCheck(UM.Preferences.getValue("view/show_overhang"))
        UM.Preferences.resetPreference("view/center_on_select");
        centerOnSelectCheckbox.checked = boolCheck(UM.Preferences.getValue("view/center_on_select"))
        UM.Preferences.resetPreference("view/top_layer_count");
        topLayerCountCheckbox.checked = boolCheck(UM.Preferences.getValue("view/top_layer_count"))

        UM.Preferences.resetPreference("cura/choice_on_profile_override")
        setDefaultDiscardOrKeepProfile(UM.Preferences.getValue("cura/choice_on_profile_override"))

        if (plugins.find("id", "SliceInfoPlugin") > -1) {
            UM.Preferences.resetPreference("info/send_slice_info")
            sendDataCheckbox.checked = boolCheck(UM.Preferences.getValue("info/send_slice_info"))
        }
        if (plugins.find("id", "UpdateChecker") > -1) {
            UM.Preferences.resetPreference("info/automatic_update_check")
            checkUpdatesCheckbox.checked = boolCheck(UM.Preferences.getValue("info/automatic_update_check"))
        }
    }

    ScrollView
    {
        width: parent.width
        height: parent.height

        Column
        {
            //: Model used to check if a plugin exists
            UM.PluginsModel { id: plugins }

            //: Language selection label
            UM.I18nCatalog{id: catalog; name:"cura"}

            Label
            {
                font.bold: true
                text: catalog.i18nc("@label","Interface")
            }

            Row
            {
                spacing: UM.Theme.getSize("default_margin").width
                Label
                {
                    id: languageLabel
                    text: catalog.i18nc("@label","Language:")
                    anchors.verticalCenter: languageComboBox.verticalCenter
                }

                ComboBox
                {
                    id: languageComboBox
                    model: ListModel
                    {
                        id: languageList

                        Component.onCompleted: {
                            append({ text: "简体中文", code: "cn" }) 
							append({ text: "English", code: "en" })
                            append({ text: "Deutsch", code: "de" })
                            append({ text: "Español", code: "es" })
                            append({ text: "Suomi", code: "fi" })
                            append({ text: "Français", code: "fr" })
                            append({ text: "Italiano", code: "it" })
                            append({ text: "Nederlands", code: "nl" })
                            append({ text: "Português do Brasil", code: "ptbr" })
                            append({ text: "Русский", code: "ru" })
                            append({ text: "Türkçe", code: "tr" })
                        }
                    }

                    currentIndex:
                    {
                        var code = UM.Preferences.getValue("general/language");
                        for(var i = 0; i < languageList.count; ++i)
                        {
                            if(model.get(i).code == code)
                            {
                                return i
                            }
                        }
                    }
                    onActivated: UM.Preferences.setValue("general/language", model.get(index).code)

                    Component.onCompleted:
                    {
                        // Because ListModel is stupid and does not allow using qsTr() for values.
                        for(var i = 0; i < languageList.count; ++i)
                        {
                            languageList.setProperty(i, "text", catalog.i18n(languageList.get(i).text));
                        }

                        // Glorious hack time. ComboBox does not update the text properly after changing the
                        // model. So change the indices around to force it to update.
                        currentIndex += 1;
                        currentIndex -= 1;
                    }
                }

                Label
                {
                    id: currencyLabel
                    text: catalog.i18nc("@label","Currency:")
                    anchors.verticalCenter: languageComboBox.verticalCenter
                }
                TextField
                {
                    id: currencyField
                    text: UM.Preferences.getValue("cura/currency")
                    onTextChanged: UM.Preferences.setValue("cura/currency", text)
                }
            }

            Label
            {
                id: languageCaption

                //: Language change warning
                text: catalog.i18nc("@label", "You will need to restart the application for language changes to have effect.")
                wrapMode: Text.WordWrap
                font.italic: true
            }

            Item
            {
                //: Spacer
                height: UM.Theme.getSize("default_margin").height
                width: UM.Theme.getSize("default_margin").width
            }

            UM.TooltipArea
            {
                width: childrenRect.width;
                height: childrenRect.height;

                text: catalog.i18nc("@info:tooltip","Slice automatically when changing settings.")

                CheckBox
                {
                    id: autoSliceCheckbox

                    checked: boolCheck(UM.Preferences.getValue("general/auto_slice"))
                    onClicked: UM.Preferences.setValue("general/auto_slice", checked)

                    text: catalog.i18nc("@option:check","Slice automatically");
                }
            }

            Item
            {
                //: Spacer
                height: UM.Theme.getSize("default_margin").height
                width: UM.Theme.getSize("default_margin").width
            }

            Label
            {
                font.bold: true
                text: catalog.i18nc("@label","Viewport behavior")
            }

            UM.TooltipArea
            {
                width: childrenRect.width;
                height: childrenRect.height;

                text: catalog.i18nc("@info:tooltip","Highlight unsupported areas of the model in red. Without support these areas will not print properly.")

                CheckBox
                {
                    id: showOverhangCheckbox

                    checked: boolCheck(UM.Preferences.getValue("view/show_overhang"))
                    onClicked: UM.Preferences.setValue("view/show_overhang",  checked)

                    text: catalog.i18nc("@option:check","Display overhang");
                }
            }

            UM.TooltipArea {
                width: childrenRect.width;
                height: childrenRect.height;
                text: catalog.i18nc("@info:tooltip","Moves the camera so the model is in the center of the view when an model is selected")

                CheckBox
                {
                    id: centerOnSelectCheckbox
                    text: catalog.i18nc("@action:button","Center camera when item is selected");
                    checked: boolCheck(UM.Preferences.getValue("view/center_on_select"))
                    onClicked: UM.Preferences.setValue("view/center_on_select",  checked)
                    enabled: Qt.platform.os != "windows" // Hack: disable the feature on windows as it's broken for pyqt 5.7.1.
                }
            }

            UM.TooltipArea {
                width: childrenRect.width
                height: childrenRect.height
                text: catalog.i18nc("@info:tooltip", "Should models on the platform be moved so that they no longer intersect?")

                CheckBox
                {
                    id: pushFreeCheckbox
                    text: catalog.i18nc("@option:check", "Ensure models are kept apart")
                    checked: boolCheck(UM.Preferences.getValue("physics/automatic_push_free"))
                    onCheckedChanged: UM.Preferences.setValue("physics/automatic_push_free", checked)
                }
            }
            UM.TooltipArea {
                width: childrenRect.width
                height: childrenRect.height
                text: catalog.i18nc("@info:tooltip", "Should models on the platform be moved down to touch the build plate?")

                CheckBox
                {
                    id: dropDownCheckbox
                    text: catalog.i18nc("@option:check", "Automatically drop models to the build plate")
                    checked: boolCheck(UM.Preferences.getValue("physics/automatic_drop_down"))
                    onCheckedChanged: UM.Preferences.setValue("physics/automatic_drop_down", checked)
                }
            }


            UM.TooltipArea
            {
                width: childrenRect.width;
                height: childrenRect.height;

                text: catalog.i18nc("@info:tooltip","Show caution message in gcode reader.")

                CheckBox
                {
                    id: gcodeShowCautionCheckbox

                    checked: boolCheck(UM.Preferences.getValue("gcodereader/show_caution"))
                    onClicked: UM.Preferences.setValue("gcodereader/show_caution", checked)

                    text: catalog.i18nc("@option:check","Caution message in gcode reader");
                }
            }

            UM.TooltipArea {
                width: childrenRect.width
                height: childrenRect.height
                text: catalog.i18nc("@info:tooltip", "Should layer be forced into compatibility mode?")

                CheckBox
                {
                    id: forceLayerViewCompatibilityModeCheckbox
                    text: catalog.i18nc("@option:check", "Force layer view compatibility mode (restart required)")
                    checked: boolCheck(UM.Preferences.getValue("view/force_layer_view_compatibility_mode"))
                    onCheckedChanged: UM.Preferences.setValue("view/force_layer_view_compatibility_mode", checked)
                }
            }

            Item
            {
                //: Spacer
                height: UM.Theme.getSize("default_margin").height
                width: UM.Theme.getSize("default_margin").height
            }

            Label
            {
                font.bold: true
                text: catalog.i18nc("@label","Opening and saving files")
            }

            UM.TooltipArea {
                width: childrenRect.width
                height: childrenRect.height
                text: catalog.i18nc("@info:tooltip","Should models be scaled to the build volume if they are too large?")

                CheckBox
                {
                    id: scaleToFitCheckbox
                    text: catalog.i18nc("@option:check","Scale large models")
                    checked: boolCheck(UM.Preferences.getValue("mesh/scale_to_fit"))
                    onCheckedChanged: UM.Preferences.setValue("mesh/scale_to_fit", checked)
                }
            }

            UM.TooltipArea {
                width: childrenRect.width
                height: childrenRect.height
                text: catalog.i18nc("@info:tooltip","An model may appear extremely small if its unit is for example in meters rather than millimeters. Should these models be scaled up?")

                CheckBox
                {
                    id: scaleTinyCheckbox
                    text: catalog.i18nc("@option:check","Scale extremely small models")
                    checked: boolCheck(UM.Preferences.getValue("mesh/scale_tiny_meshes"))
                    onCheckedChanged: UM.Preferences.setValue("mesh/scale_tiny_meshes", checked)
                }
            }

            UM.TooltipArea {
                width: childrenRect.width
                height: childrenRect.height
                text: catalog.i18nc("@info:tooltip", "Should a prefix based on the printer name be added to the print job name automatically?")

                CheckBox
                {
                    id: prefixJobNameCheckbox
                    text: catalog.i18nc("@option:check", "Add machine prefix to job name")
                    checked: boolCheck(UM.Preferences.getValue("cura/jobname_prefix"))
                    onCheckedChanged: UM.Preferences.setValue("cura/jobname_prefix", checked)
                }
            }

            UM.TooltipArea {
                width: childrenRect.width
                height: childrenRect.height
                text: catalog.i18nc("@info:tooltip", "Should a summary be shown when saving a project file?")

                CheckBox
                {
                    text: catalog.i18nc("@option:check", "Show summary dialog when saving project")
                    checked: boolCheck(UM.Preferences.getValue("cura/dialog_on_project_save"))
                    onCheckedChanged: UM.Preferences.setValue("cura/dialog_on_project_save", checked)
                }
            }

            Item
            {
                //: Spacer
                height: UM.Theme.getSize("default_margin").height
                width: UM.Theme.getSize("default_margin").width
            }

            UM.TooltipArea
            {
                width: childrenRect.width;
                height: childrenRect.height;

                text: catalog.i18nc("@info:tooltip", "When you have made changes to a profile and switched to a different one, a dialog will be shown asking whether you want to keep your modifications or not, or you can choose a default behaviour and never show that dialog again.")

                Column
                {
                    spacing: 4

                    Label
                    {
                        font.bold: true
                        text: catalog.i18nc("@label", "Override Profile")
                    }

                    ComboBox
                    {
                        id: choiceOnProfileOverrideDropDownButton
                        width: 200

                        model: ListModel
                        {
                            id: discardOrKeepProfileListModel

                            Component.onCompleted: {
                                append({ text: catalog.i18nc("@option:discardOrKeep", "Always ask me this"), code: "always_ask" })
                                append({ text: catalog.i18nc("@option:discardOrKeep", "Discard and never ask again"), code: "always_discard" })
                                append({ text: catalog.i18nc("@option:discardOrKeep", "Keep and never ask again"), code: "always_keep" })
                            }
                        }

                        currentIndex:
                        {
                            var index = 0;
                            var code = UM.Preferences.getValue("cura/choice_on_profile_override");
                            for (var i = 0; i < model.count; ++i)
                            {
                                if (model.get(i).code == code)
                                {
                                    index = i;
                                    break;
                                }
                            }
                            return index;
                        }
                        onActivated: UM.Preferences.setValue("cura/choice_on_profile_override", model.get(index).code)
                    }
                }
            }

            Item
            {
                //: Spacer
                height: UM.Theme.getSize("default_margin").height
                width: UM.Theme.getSize("default_margin").height
            }

            Label
            {
                font.bold: true
                visible: checkUpdatesCheckbox.visible || sendDataCheckbox.visible
                text: catalog.i18nc("@label","Privacy")
            }

            UM.TooltipArea {
                visible: plugins.find("id", "UpdateChecker") > -1
                width: childrenRect.width
                height: visible ? childrenRect.height : 0
                text: catalog.i18nc("@info:tooltip","Should Cura check for updates when the program is started?")

                CheckBox
                {
                    id: checkUpdatesCheckbox
                    text: catalog.i18nc("@option:check","Check for updates on start")
                    checked: boolCheck(UM.Preferences.getValue("info/automatic_update_check"))
                    onCheckedChanged: UM.Preferences.setValue("info/automatic_update_check", checked)
                }
            }

            UM.TooltipArea {
                visible: plugins.find("id", "SliceInfoPlugin") > -1
                width: childrenRect.width
                height: visible ? childrenRect.height : 0
                text: catalog.i18nc("@info:tooltip","Should anonymous data about your print be sent to Ultimaker? Note, no models, IP addresses or other personally identifiable information is sent or stored.")

                CheckBox
                {
                    id: sendDataCheckbox
                    text: catalog.i18nc("@option:check","Send (anonymous) print information")
                    checked: boolCheck(UM.Preferences.getValue("info/send_slice_info"))
                    onCheckedChanged: UM.Preferences.setValue("info/send_slice_info", checked)
                }
            }
        }
    }
}
