

public struct ShippingRule {
  public let cost: Double
  public let id: Int?
  public let location: Location
  public let estimatedMin: Money?
  public let estimatedMax: Money?
}

extension ShippingRule: Decodable {
  enum CodingKeys: String, CodingKey {
    case cost
    case id
    case location
    case estimatedMin
    case estimatedMax
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.cost = try Double(values.decode(String.self, forKey: .cost)) ?? 0
    self.id = try values.decodeIfPresent(Int.self, forKey: .id)
    self.location = try values.decode(Location.self, forKey: .location)
    self.estimatedMin = try values.decodeIfPresent(Money.self, forKey: .estimatedMin)
    self.estimatedMax = try values.decodeIfPresent(Money.self, forKey: .estimatedMax)
  }
}

extension ShippingRule: Equatable {}
public func == (lhs: ShippingRule, rhs: ShippingRule) -> Bool {
  // TODO: change to compare id once that api is deployed
  return lhs.location == rhs.location
}
