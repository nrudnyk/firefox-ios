// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import UIKit
import Shared

/// Each scene has it's own scene coordinator, which is the root coordinator for a scene.
class SceneCoordinator: BaseCoordinator, LaunchFinishedLoadingDelegate {
    var window: UIWindow?

    init(scene: UIScene,
         sceneSetupHelper: SceneSetupHelper = SceneSetupHelper()) {
        self.window = sceneSetupHelper.configureWindowFor(scene, screenshotServiceDelegate: nil)
        let navigationController = sceneSetupHelper.createNavigationController()
        let router = DefaultRouter(navigationController: navigationController)
        super.init(router: router)

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func start() {
        let launchScreenVC = LaunchScreenViewController(coordinator: self)
        router.setRootViewController(launchScreenVC, hideBar: true)
    }

    // MARK: - LaunchFinishedLoadingDelegate

    func launchWith(launchType: LaunchType) {
        guard launchType.canLaunch(fromType: .SceneCoordinator) else {
            startBrowser(with: launchType)
            return
        }

        startLaunch(with: launchType)
    }

    func launchBrowser() {
        startBrowser(with: nil)
    }

    // MARK: - Helper methods

    private func startLaunch(with launchType: LaunchType) {
        let launchCoordinator = LaunchCoordinator(router: router)
        add(child: launchCoordinator)
        launchCoordinator.start(with: launchType) {
            self.remove(child: launchCoordinator)
            self.startBrowser(with: nil)
        }
    }

    private func startBrowser(with launchType: LaunchType?) {
        let browserCoordinator = BrowserCoordinator(router: router)
        add(child: browserCoordinator)
        browserCoordinator.start(with: launchType)
    }
}
