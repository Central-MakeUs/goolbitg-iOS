//
//  ProjectConfig.swift
//  TuistExtensions
//
//  Created by Jae hyung Kim on 5/18/25.
//

import ProjectDescription
import Foundation

public protocol ProjectConfigProtocol {
    var name: String { get }
    var product: Product { get }
    var bundleId: String? { get }
    var deploymentTargets: DeploymentTargets { get }
    var schemes: [Scheme] { get }
    var customTargets: [Target] { get }
    var packages: [Package] { get }
    var scripts: [TargetScript] { get }
    var dependencies: [TargetDependency] { get }
    var resources: ResourceFileElements? { get }
    var sources: SourceFilesList? { get }
    var testSources: SourceFilesList? { get }
}

public struct ProjectConfig: ProjectConfigProtocol {
    
    public var name: String
    
    public var product: Product
    
    public var bundleId: String?
    
    public var deploymentTargets: DeploymentTargets
    
    public var schemes: [Scheme]
    
    public var customTargets: [Target]
    
    public var packages: [Package]
    
    public var scripts: [TargetScript]
    
    public var dependencies: [TargetDependency]
    
    public var resources: ResourceFileElements?
    
    public var sources: SourceFilesList?
    
    public var testSources: SourceFilesList?
    
    // MARK: Init
    public init(
        name: String,
        product: Product,
        bundleID: String? = nil,
        deploymentTargets: DeploymentTargets,
        schemes: [Scheme] = [],
        customTargets: [Target] = [],
        packages: [Package] = [],
        scripts: [TargetScript] = [],
        dependencies: [TargetDependency] = [],
        resources: ResourceFileElements? = nil,
        sources: SourceFilesList? = nil,
        testSources: SourceFilesList? = nil
    ) {
        self.name = name
        self.product = product
        self.bundleId = bundleID
        self.deploymentTargets = deploymentTargets
        self.schemes = schemes
        self.customTargets = customTargets
        self.packages = packages
        self.scripts = scripts
        self.dependencies = dependencies
        self.resources = resources
        self.sources = sources
        self.testSources = testSources
    }
}

public struct FrameworkConfig: ProjectConfigProtocol {
    
    public var name: String
    
    public var product: Product
    
    public var bundleId: String?
    
    public var deploymentTargets: DeploymentTargets
    
    public var schemes: [Scheme]
    
    public var customTargets: [Target]
    
    public var packages: [Package]
    
    public var scripts: [TargetScript]
    
    public var dependencies: [TargetDependency]
    
    public var resources: ResourceFileElements?
    
    public var sources: SourceFilesList?
    
    public var testSources: SourceFilesList?
    
    
    public init(
        name: String,
        deploymentTargets: DeploymentTargets,
        bundleID: String? = nil,
        schemes: [Scheme] = [],
        customTargets: [Target] = [],
        packages: [Package] = [],
        scripts: [TargetScript] = [],
        dependencies: [TargetDependency] = [],
        resources: ResourceFileElements? = nil,
        sources: SourceFilesList?,
        testSources: SourceFilesList? = []
    ) {
        self.name = name
        self.product = .framework
        self.bundleId = bundleID
        self.deploymentTargets = deploymentTargets
        self.schemes = schemes
        self.customTargets = customTargets
        self.packages = packages
        self.scripts = scripts
        self.dependencies = dependencies
        self.resources = resources
        self.sources = sources
        self.testSources = testSources
    }
}
