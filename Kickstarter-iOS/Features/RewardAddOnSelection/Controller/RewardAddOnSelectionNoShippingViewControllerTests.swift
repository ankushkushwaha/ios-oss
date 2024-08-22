@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import SnapshotTesting
import UIKit

final class RewardAddOnSelectionNoShippingViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()

    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)

    super.tearDown()
  }

  func testView() {
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.localPickup .~ nil
      |> Reward.lens.isAvailable .~ true

    let noShippingAddOn = Reward.template
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.none
      |> Reward.lens.localPickup .~ nil
      |> Reward.lens.isAvailable .~ true

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ [noShippingAddOn]

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(project))

    let mockRemoteConfigClient = MockRemoteConfigClient()
      |> \.features .~ [RemoteConfigFeature.noShippingAtCheckout.rawValue: true]

    orthogonalCombos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        language: language,
        remoteConfigClient: mockRemoteConfigClient
      ) {
        let controller = RewardAddOnSelectionNoShippingViewController.instantiate()

        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          selectedShippingRule: nil,
          selectedQuantities: [:],
          selectedLocationId: nil,
          refTag: nil,
          context: .pledge
        )
        controller.configure(with: data)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 600

        self.scheduler.advance()

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testView_EmptyState() {
    let shippingRules = [
      ShippingRule.template
        |> ShippingRule.lens.location .~ .brooklyn,
      ShippingRule.template
        |> ShippingRule.lens.location .~ .canada,
      ShippingRule.template
        |> ShippingRule.lens.location .~ .australia
    ]

    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 55)

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .restricted
      |> Reward.lens.id .~ 99
      |> Reward.lens.shippingRules .~ [shippingRule]
      |> Reward.lens.localPickup .~ nil
      |> Reward.lens.isAvailable .~ true

    let shippingAddOn1 = Reward.template
      |> Reward.lens.id .~ 2
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRules .~ [
        shippingRule |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 99)
      ]
      |> Reward.lens.localPickup .~ nil
      |> Reward.lens.isAvailable .~ true

    let shippingAddOn2 = Reward.template
      |> Reward.lens.id .~ 3
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRules .~ [
        shippingRule |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 99)
      ]
      |> Reward.lens.localPickup .~ nil
      |> Reward.lens.isAvailable .~ true

    let shippingAddOn3 = Reward.template
      |> Reward.lens.id .~ 4
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRules .~ [
        shippingRule |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 3)
      ]
      |> Reward.lens.localPickup .~ nil
      |> Reward.lens.isAvailable .~ true

    let shippingAddOn4 = Reward.template
      |> Reward.lens.id .~ 5
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRules .~ [
        shippingRule |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 3)
      ]
      |> Reward.lens.localPickup .~ nil
      |> Reward.lens.isAvailable .~ true

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ [
        shippingAddOn1,
        shippingAddOn2,
        shippingAddOn3,
        shippingAddOn4
      ]

    let mockService = MockService(
      fetchShippingRulesResult: .success(shippingRules),
      fetchRewardAddOnsSelectionViewRewardsResult: .success(project)
    )

    let mockRemoteConfigClient = MockRemoteConfigClient()
      |> \.features .~ [RemoteConfigFeature.noShippingAtCheckout.rawValue: true]

    orthogonalCombos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        language: language,
        remoteConfigClient: mockRemoteConfigClient
      ) {
        let controller = RewardAddOnSelectionNoShippingViewController.instantiate()
        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          selectedShippingRule: nil,
          selectedQuantities: [:],
          selectedLocationId: nil,
          refTag: nil,
          context: .pledge
        )
        controller.configure(with: data)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 600

        self.scheduler.advance()

        self.scheduler.advance(by: .seconds(1))

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testView_Error() {
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.localPickup .~ nil
    let project = Project.template

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .failure(.couldNotParseJSON))

    let mockRemoteConfigClient = MockRemoteConfigClient()
      |> \.features .~ [RemoteConfigFeature.noShippingAtCheckout.rawValue: true]

    orthogonalCombos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        language: language,
        remoteConfigClient: mockRemoteConfigClient
      ) {
        let controller = RewardAddOnSelectionNoShippingViewController.instantiate()

        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          selectedShippingRule: nil,
          selectedQuantities: [:],
          selectedLocationId: nil,
          refTag: nil,
          context: .pledge
        )
        controller.configure(with: data)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 600

        self.scheduler.advance()

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testView_NoShippingWithLocalPickup_Success() {
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.localPickup .~ .australia
      |> Reward.lens.shipping.preference .~ .local
      |> Reward.lens.isAvailable .~ true

    let noShippingAddOn = Reward.template
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.shipping.preference .~ .local
      |> Reward.lens.localPickup .~ .australia
      |> Reward.lens.isAvailable .~ true

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ [noShippingAddOn]

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(project))

    let mockRemoteConfigClient = MockRemoteConfigClient()
      |> \.features .~ [RemoteConfigFeature.noShippingAtCheckout.rawValue: true]

    orthogonalCombos(Language.allLanguages, [Device.phone5_8inch, Device.pad]).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        language: language,
        remoteConfigClient: mockRemoteConfigClient
      ) {
        let controller = RewardAddOnSelectionNoShippingViewController.instantiate()

        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          selectedShippingRule: nil,
          selectedQuantities: [:],
          selectedLocationId: nil,
          refTag: nil,
          context: .pledge
        )
        controller.configure(with: data)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 600

        self.scheduler.advance()

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }
}
