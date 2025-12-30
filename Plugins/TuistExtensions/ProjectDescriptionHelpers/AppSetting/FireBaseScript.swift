//
//  FireBaseScript.swift
//  TuistExtensions
//
//  Created by Jae hyung Kim on 6/23/25.
//

import Foundation
import ProjectDescription

private let fireBaseRunScript = """
#!/bin/sh

echo "[Script] CHECKING dSYM: ${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}"
ls -l "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}"

"${PROJECT_DIR}/../../Tuist/.build/checkouts/firebase-ios-sdk/Crashlytics/run"
"""

let fireBaseInfoPlistScript = """
#!/bin/sh

PATH_TO_GOOGLE_PLISTS="${PROJECT_DIR}/../../AppSettingFiles/InfoPlist"

echo "[Script] Checking Dev plist path: $PATH_TO_GOOGLE_PLISTS/GoogleService-Dev-Info.plist"
echo "[Script] Checking BUILT_PRODUCTS_DIR: ${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}"

case "${CONFIGURATION}" in
   "Dev")
    echo "[Script] Checking Dev MODE"
     cp "$PATH_TO_GOOGLE_PLISTS/GoogleService-Dev-Info.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
     ;;
   *)
    echo "[Script] Checking LIVE MODE"
     cp "$PATH_TO_GOOGLE_PLISTS/GoogleService-Live-Info.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
     ;;
esac
"""


extension TargetScript {
    public static let fireBase = Self.pre(
        script: fireBaseInfoPlistScript,
        name: "FirebaseInfoPlistScript",
        basedOnDependencyAnalysis: false
    )
    
    public static let fireBaseCrashlyticsRun = Self.post(
        script: fireBaseRunScript,
        name: "Firebase Crashlytics",
        inputPaths: [
            "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}",
            "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${PRODUCT_NAME}",
            "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Info.plist",
            "$(TARGET_BUILD_DIR)/$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/GoogleService-Info.plist",
            "$(TARGET_BUILD_DIR)/$(EXECUTABLE_PATH)"
        ],
        basedOnDependencyAnalysis: false
    )
        
}

/*
 "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}",
 "$(SRCROOT)/$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)",
*/
