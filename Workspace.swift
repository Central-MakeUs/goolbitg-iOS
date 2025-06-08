import TuistExtensions
import ProjectDescription
import Foundation

let workSpace = Workspace(
    name: "Goolbitg-iOS",
    projects: (
        [
            AppConfig.appPath,
            DomainConfig.path,
        ] + Module.modules.map(
            \.path
        ) + DemoApps.allCases.map(
            \.onlyTargetPath
        )
    )
)
