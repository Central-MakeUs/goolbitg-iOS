import TuistExtensions
import ProjectDescription
import Foundation

private let appPath: Path = .relativeToRoot(
    "Projects/App"
)

let workSpace = Workspace(
    name: "Goolbitg-iOS",
    projects: (
        [
            appPath,
            DomainConfig.path,
        ] + Module.modules.map(
            \.path
        ) + DemoApps.allCases.map(
            \.onlyTargetPath
        )
    )
)
