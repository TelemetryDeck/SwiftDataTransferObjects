// https://stackoverflow.com/a/52239535/54547
// https://github.com/VaporExamplesLab/Example-SO-VaporJsonResponse/blob/master/CuisineDishes/Sources/App/Models/Dish.swift

import Foundation

struct Links: Codable {
    var current: String?
    var next: String?
    var last: String?
}

struct ApiResponseGeneric<T>: Codable where T: Codable {
    var links: Links?
    var data: T

    init(links: Links, data: T) {
        self.links = links
        self.data = data
    }
}
