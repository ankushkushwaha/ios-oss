import Foundation
import Library
import SwiftUI

public class PPOContainerViewController: PagedContainerViewController {
  public override func viewDidLoad() {
    super.viewDidLoad()

    // TODO: Translate these strings (MBL-1558)
    self.title = "Activity"
    let ppoViewController = UIHostingController(rootView: PPOView())
    ppoViewController.title = "Project Alerts"

    let activitiesViewController = ActivitiesViewController.instantiate()
    activitiesViewController.title = "Activity Feed"

    self.setPagedViewControllers([ppoViewController, activitiesViewController])
  }
}
