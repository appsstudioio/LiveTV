//
//  ComponentFont.swift
//  LiveTV
//
//  Created by 10-N3344 on 2023/09/01.
//

import Foundation
import UIKit

public enum ComponentFont {
    case r08px, sb08px, b08px
    case r09px, sb09px, b09px
    case r10px, sb10px, b10px
    case r11px, sb11px, b11px
    case r12px, sb12px, b12px
    case r13px, sb13px, b13px
    case r14px, sb14px, b14px
    case r15px, sb15px, b15px
    case r16px, sb16px, b16px
    case r17px, sb17px, b17px
    case r18px, sb18px, b18px
    case r19px, sb19px, b19px
    case r20px, sb20px, b20px
    case r21px, sb21px, b21px
    case r22px, sb22px, b22px
    case r23px, sb23px, b23px
    case r24px, sb24px, b24px
    case r25px, sb25px, b25px
    case r26px, sb26px, b26px
    case r27px, sb27px, b27px
    case r28px, sb28px, b28px
    case r29px, sb29px, b29px
    case r30px, sb30px, b30px
    case r31px, sb31px, b31px
    case r32px, sb32px, b32px
    case r33px, sb33px, b33px
    case r34px, sb34px, b34px
}

extension ComponentFont {
    public static func font(weight: UIFont.Weight, size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: weight)
    }

    public var font: UIFont {
        return UIFont.systemFont(ofSize: self.fontSize, weight: self.weight)
    }

    var fontSize: CGFloat {
        switch self {
        case .r08px, .sb08px, .b08px:
            return 8.0
        case .r09px, .sb09px, .b09px:
            return 9.0
        case .r10px, .sb10px, .b10px:
            return 10.0
        case .r11px, .sb11px, .b11px:
            return 11.0
        case .r12px, .sb12px, .b12px:
            return 12.0
        case .r13px, .sb13px, .b13px:
            return 13.0
        case .r14px, .sb14px, .b14px:
            return 14.0
        case .r15px, .sb15px, .b15px:
            return 15.0
        case .r16px, .sb16px, .b16px:
            return 16.0
        case .r17px, .sb17px, .b17px:
            return 17.0
        case .r18px, .sb18px, .b18px:
            return 18.0
        case .r19px, .sb19px, .b19px:
            return 19.0
        case .r20px, .sb20px, .b20px:
            return 20.0
        case .r21px, .sb21px, .b21px:
            return 21.0
        case .r22px, .sb22px, .b22px:
            return 22.0
        case .r23px, .sb23px, .b23px:
            return 23.0
        case .r24px, .sb24px, .b24px:
            return 24.0
        case .r25px, .sb25px, .b25px:
            return 25.0
        case .r26px, .sb26px, .b26px:
            return 26.0
        case .r27px, .sb27px, .b27px:
            return 27.0
        case .r28px, .sb28px, .b28px:
            return 28.0
        case .r29px, .sb29px, .b29px:
            return 29.0
        case .r30px, .sb30px, .b30px:
            return 30.0
        case .r31px, .sb31px, .b31px:
            return 31.0
        case .r32px, .sb32px, .b32px:
            return 32.0
        case .r33px, .sb33px, .b33px:
            return 33.0
        case .r34px, .sb34px, .b34px:
            return 34.0
        }
    }

    var lineHeight: CGFloat {
        switch self {
        case .r08px, .sb08px, .b08px:
            return 11.0
        case .r09px, .sb09px, .b09px:
            return 12.0
        case .r10px, .sb10px, .b10px:
            return 13.0
        case .r11px, .sb11px, .b11px:
            return 14.0
        case .r12px, .sb12px, .b12px:
            return 15.0
        case .r13px, .sb13px, .b13px:
            return 16.0
        case .r14px, .sb14px, .b14px:
            return 19.0
        case .r15px, .sb15px, .b15px:
            return 20.0
        case .r16px, .sb16px, .b16px:
            return 21.0
        case .r17px, .sb17px, .b17px:
            return 22.0
        case .r18px, .sb18px, .b18px:
            return 23.0
        case .r19px, .sb19px, .b19px:
            return 24.0
        case .r20px, .sb20px, .b20px:
            return 25.0
        case .r21px, .sb21px, .b21px:
            return 26.0
        case .r22px, .sb22px, .b22px:
            return 28.0
        case .r23px, .sb23px, .b23px:
            return 29.0
        case .r24px, .sb24px, .b24px:
            return 30.0
        case .r25px, .sb25px, .b25px:
            return 31.0
        case .r26px, .sb26px, .b26px:
            return 32.0
        case .r27px, .sb27px, .b27px:
            return 33.0
        case .r28px, .sb28px, .b28px:
            return 34.0
        case .r29px, .sb29px, .b29px:
            return 35.0
        case .r30px, .sb30px, .b30px:
            return 37.0
        case .r31px, .sb31px, .b31px:
            return 38.0
        case .r32px, .sb32px, .b32px:
            return 39.0
        case .r33px, .sb33px, .b33px:
            return 40.0
        case .r34px, .sb34px, .b34px:
            return 41.0
        }
    }
    
    var fontLineHeight: CGFloat {
        return ComponentFont.font(weight: self.weight, size: self.fontSize).lineHeight
    }

    var fontDescender: CGFloat {
        return ComponentFont.font(weight: self.weight, size: self.fontSize).descender
    }

    var weight: UIFont.Weight {
        switch self {
        case .b08px, .b09px, .b10px, .b11px, .b12px, .b13px, .b14px,
                .b15px, .b16px, .b17px, .b18px, .b19px,
                .b20px, .b21px, .b22px, .b23px, .b24px,
                .b25px, .b26px, .b27px, .b28px, .b29px,
                .b30px, .b31px, .b32px, .b33px, .b34px
            :
            return .bold
        case .sb08px, .sb09px, .sb10px, .sb11px, .sb12px, .sb13px, .sb14px,
                .sb15px, .sb16px, .sb17px, .sb18px, .sb19px,
                .sb20px, .sb21px, .sb22px, .sb23px, .sb24px,
                .sb25px, .sb26px, .sb27px, .sb28px, .sb29px,
                .sb30px, .sb31px, .sb32px, .sb33px, .sb34px
            :
            return .semibold
        case .r08px, .r09px, .r10px, .r11px, .r12px, .r13px, .r14px,
                .r15px, .r16px, .r17px, .r18px, .r19px,
                .r20px, .r21px, .r22px, .r23px, .r24px,
                .r25px, .r26px, .r27px, .r28px, .r29px,
                .r30px, .r31px, .r32px, .r33px, .r34px
            :
            return .regular
        }
    }
}
