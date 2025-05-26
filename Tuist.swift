import ProjectDescription

let tuist = Tuist(
    project: TuistProject.tuist(
        plugins: [
            .local(
                path: "../Plugins/TuistExtensions"
            )
        ]
    )
)
