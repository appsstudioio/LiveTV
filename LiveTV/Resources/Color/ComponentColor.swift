//
//  ComponentColor.swift
//  LiveTV
//
//  Created by 10-N3344 on 2023/09/01.
//

import UIKit

public enum ComponentColor: String {
    case backgroundBoxColor
    case backgroundColor
    case backgroundDimm
    case backgroundDisable
    case backgroundGray
    case badgeColor
    case borderDisable
    case borderOpaque
    case borderTransparent
    case contentDisable
    case contentPlaceHolder
    case contentPrimary
    case contentSecondary
    case contentTertiary
    case contentWhite
    case error
    case mainColor
    case replyTagColor
    case shadowColor
    case success
    case textBoxDisable
    case warning
    case r101g158b255
    case r102g102b102
    case r104g137b179
    case r106g127b137
    case r112g112b112
    case r113g113b115
    case r121g126b132
    case r127g164b211
    case r128g128b128
    case r130g130b130
    case r132g146b160
    case r135g212b228
    case r143g150b156
    case r148g148b148
    case r151g152b157
    case r152g107b203
    case r152g166b181
    case r153g153b153
    case r163g163b163
    case r168g168b168
    case r173g153b252
    case r178g179b182
    case r180g188b192
    case r181g181b181
    case r184g184b184
    case r185g185b185
    case r188g198b207
    case r193g193b193
    case r199g199b199
    case r207g207b215
    case r219g223b224
    case r220g53b69
    case r220g220b220
    case r224g224b224
    case r231g251b254
    case r231g248b255
    case r234g234b234
    case r236g247b251
    case r238g242b245
    case r241g243b245
    case r242g242b242
    case r243g243b243
    case r244g244b244
    case r247g247b249
    case r246g246b246
    case r248g248b248
    case r246g248b250
    case r249g249b249
    case r251g160b1
    case r251g251b251
    case r252g155b41
    case r252g178b46
    case r255g56b90
    case r255g126b126
    case r255g128b0
    case r255g253b238
    case r14g207b239
    case r25g25b25
    case r32g32b32
    case r38g209b120
    case r39g41b44
    case r41g41b41
    case r48g124b229
    case r49g136b244
    case r50g251b146
    case r51g51b51
    case r51g61b71
    case r51g136b243
    case r53g158b255
    case r54g54b55
    case r60g60b60
    case r63g167b240
    case r63g162b254
    case r66g185b235
    case r73g193b241
    case r76g76b76
    case r85g85b85
    case r90g163b247
    case r93g93b93
}

extension UIColor {
    public static func named(_ name: ComponentColor) -> UIColor {
        return UIColor(named: name.rawValue) ?? .clear
    }
}
