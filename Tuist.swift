//
//  Tuist.swift
//  Packages
//
//  Created by Jae hyung Kim on 6/8/25.
//

import ProjectDescription

let tuist = Tuist(
    project: TuistProject.tuist(
        plugins: [
            .local(
                path: .relativeToRoot("Plugins/TuistExtensions")
            )
        ]
    )
)
