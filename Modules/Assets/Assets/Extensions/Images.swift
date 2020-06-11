import UIKit

public struct Images {
    public static var startLabel: UIImage { UIImage(named: "icStartLabel", in: Assets.bundle, compatibleWith: nil)! }
    public static var endLabel: UIImage { UIImage(named: "icEndLabel", in: Assets.bundle, compatibleWith: nil)! }

    public struct TabBar {
        public static var timer: UIImage { UIImage(named: "icTime", in: Assets.bundle, compatibleWith: nil)! }
        
        public static var reports: UIImage { UIImage(named: "icReports", in: Assets.bundle, compatibleWith: nil)! }
        
        public static var calendar: UIImage { UIImage(named: "icCalendar", in: Assets.bundle, compatibleWith: nil)! }
    }

    public struct Calendar {
        public static var calendarSmall: UIImage {
            UIImage(named: "icCalendarSmall", in: Assets.bundle, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
        }
        
        public static var stripesPattern: UIImage {
            UIImage(named: "stripes", in: Assets.bundle, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
        }
    }
}
