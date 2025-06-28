public typealias Colour = Int

// ---------------------------------------------------------------------------------------------------------------------
// ios-cellgridview
// ---------------------------------------------------------------------------------------------------------------------

// FILE: ios-cellgridview/CellGridView+Defaults.swift
//
extension CellGridView
{
    public class Defaults {
        public static let viewBackground: Colour  = 123
        public static let viewTransparency: UInt8 = 255
        public static let viewScaling: Bool       = true
        public static let cellSize: Int           = 43
        public static let cellPadding: Int        = 2
    }
}

// FILE: ios-cellgridview/CellGridView+Config.swift
//
extension CellGridView
{
    public class Config {

        public private(set) var viewBackground: Colour
        public private(set) var viewTransparency: UInt8
        public private(set) var viewScaling: Bool
        public private(set) var cellSize: Int
        public private(set) var cellPadding: Int

        public init(config: CellGridView.Config? = nil,
                    viewBackground: Colour?      = nil,
                    viewTransparency: UInt8?     = nil,
                    viewScaling: Bool?           = nil,
                    cellSize: Int?               = nil,
                    cellPadding: Int?            = nil)
        {
            self.viewBackground   = viewBackground   ?? config?.viewBackground   ?? Defaults.viewBackground
            self.viewTransparency = viewTransparency ?? config?.viewTransparency ?? Defaults.viewTransparency
            self.viewScaling      = viewScaling      ?? config?.viewScaling      ?? Defaults.viewScaling
            self.cellSize         = cellSize         ?? config?.cellSize         ?? Defaults.cellSize
            self.cellPadding      = cellPadding      ?? config?.cellPadding      ?? Defaults.cellPadding
        }

        // Initializes this instance of CellGridView.Config with the properties from the given
        // CellGridView, or with the default values from CellGridView.Defaults is nil is given.
        //
        public init(_ cellGridView: CellGridView? = nil)
        {
            self.viewBackground   = cellGridView?.viewBackground   ?? Defaults.viewBackground
            self.viewTransparency = cellGridView?.viewTransparency ?? Defaults.viewTransparency
            self.viewScaling      = cellGridView?.viewScaling      ?? Defaults.viewScaling
            self.cellSize         = cellGridView?.cellSize         ?? Defaults.cellSize
            self.cellPadding      = cellGridView?.cellPadding      ?? Defaults.cellPadding
        }

        public func update(viewBackground: Colour?  = nil,
                           viewTransparency: UInt8? = nil,
                           viewScaling: Bool?       = nil,
                           cellSize: Int?           = nil,
                           cellPadding: Int?        = nil) -> CellGridView.Config
        {
            return CellGridView.Config(viewBackground:     viewBackground     ?? self.viewBackground,
                                       viewTransparency:   viewTransparency   ?? self.viewTransparency,
                                       viewScaling:        viewScaling        ?? self.viewScaling,
                                       cellSize:           cellSize           ?? self.cellSize,
                                       cellPadding:        cellPadding        ?? self.cellPadding)
        }
    }
}

// FILE: ios-cellgridview/CellGridView.swift
//
public class CellGridView
{
    public private(set) var viewBackground: Colour
    public private(set) var viewTransparency: UInt8
    public private(set) var viewScaling: Bool
    public private(set) var cellSize: Int
    public private(set) var cellPadding: Int

    public init(_ config: CellGridView.Config? = nil) {
        let config: CellGridView.Config = config ?? CellGridView.Config()
        self.viewBackground   = config.viewBackground
        self.viewTransparency = config.viewTransparency
        self.viewScaling      = config.viewScaling
        self.cellSize         = config.cellSize
        self.cellPadding      = config.cellPadding
    }

    open var config: CellGridView.Config {
        CellGridView.Config(self)
    }

    open func initialize(_ config: CellGridView.Config, fit: Bool = false, center: Bool = false) {

        if (fit) {
            //
            // Do stuff specific to cell fitting; though aybe actually do this in configure.
            //
        }

        self.configure(config)

        if (center) {
            //
            // Do stuff specific to centering the cells.
            //
        }
    }

    open func configure(_ config: CellGridView.Config) {
        self.viewBackground   = config.viewBackground
        self.viewTransparency = config.viewTransparency
        self.viewScaling      = config.viewScaling
        self.cellSize         = config.cellSize
        self.cellPadding      = config.cellPadding
    }
}

// ---------------------------------------------------------------------------------------------------------------------
// ios-lifegame
// ---------------------------------------------------------------------------------------------------------------------

// FILE: ios-lifegame/Settings.swift
//
class Settings
{
    public var viewBackground: Colour = CellGridView.Defaults.viewBackground
    public var viewScaling: Bool      = CellGridView.Defaults.viewScaling
    public var cellSize: Int          = 25
    public var cellPadding: Int       = 1
    public var activeColor: Colour    = 0x06
    public var inactiveColor: Colour  = 0x07

    // This just allows this Settings object to be the single place where we define the default parameters
    // for this app, which are easily accessible elsewhere, without having to define a separate Defaults class;
    // note that we still instantiate this class normally when passing to ContentView; it would otherwise be odd.
    //
    public static let Defaults: Settings = Settings()
}

// FILE: ios-lifegame/LifeCellGridView+Config.swift
//
extension Settings
{
    // Sets up this Settings object from the given LifeCellGridView.Config.
    // Intended to be called, for example, before showing SettingsView
    // from ContentView, something like this:
    //
    //     @EnvironmentObject var cellGridView: LifeCellGridView
    //     @EnvironmentObject var settings: Settings
    //     func gotoSettingsView() {
    //         let config: LifeCellGridView.Config = self.cellGridView.config
    //         self.settings.fromConfig(config)
    //         self.showSettingsView = true
    //     }
    //
    public func fromConfig(_ config: LifeCellGridView.Config)
    {
        // Life Game specific properties.

        self.activeColor    = config.activeColor
        self.inactiveColor  = config.inactiveColor

        // CellGridView base class specific properties.

        self.viewBackground = config.viewBackground
        self.viewScaling    = config.viewScaling
        self.cellSize       = config.cellSize
        self.cellPadding    = config.cellPadding
    }

    // Creates and returns a new LifeCellGridView.Config (derived from CellGridView.Config)
    // object, with properties initialized from this Settings object. Intended to be called,
    // for example, on return from SettingsView in ContentView, something like this:
    //
    //     @EnvironmentObject var cellGridView: LifeCellGridView
    //     @EnvironmentObject var settings: Settings
    //     func onSettingsChange() {
    //         let config: LifeCellGridView.Config = self.settings.toConfig(self.cellGridView)
    //         self.cellGridView.configure(config)
    //     }
    //
    internal func toConfig(_ cellGridView: LifeCellGridView) -> LifeCellGridView.Config
    {
        // TODO
        //
        // Hmmm. But we initially initialized this Settings object to pass into SettingsView,
        // using the above fromConfig method, with the Config for our LifeCellGridView,
        // so it should already have been set up with the properties from that, so should
        // reallly only have to copy the properties from this Settings object into a (new)
        // LifeCellGridView.Config object.
        //
        // EXCEPT the problem with the new (uncommented) code below is that when we create
        // LifeCellGridView.Config it (its constructor) goes to the trouble of initializing
        // it with (ultimately, since passing a nil LifeCellGridView object) default values
        // to its properties, which I guess is fine, but not merely wasteful but more,
        // confusing (at least for me) to reason about (i.e. later when I forget).
        //
        return LifeCellGridView.Config(cellGridView, self)
    }
}

// FILE: ios-lifegame/LifeCellGridView+Config.swift
//
extension LifeCellGridView
{
    public class Config: CellGridView.Config {

        public private(set) var activeColor: Colour
        public private(set) var inactiveColor: Colour

        // Initializes this instance of LifeCellGridView.Config with the properties from the given
        // Settings; or if this is nil then with the properties from the given LifeCellGridView;
        // or if that is nil then from the default values in Settings.Defaults.
        //
        // Note that this constructor does in fact effectively hide the base
        // class constructor which takes a CellGridView, which is what we want;
        // i.e. only allow creation of LifeCellGridView.Config with a LifeCellGridView.
        //
        // Note that the call to this with a Settings object (and non-nil LifeCellGridView object)
        // is done from the toConfig method of LifeCellGridView.Config. We do not just initialize
        // from Settings directly there because we need to initialize its CellGridView base class
        // properties, particularly those base properties which we are not interested in here.
        //
        internal init(_ cellGridView: LifeCellGridView? = nil, _ settings: Settings? = nil)
        {
            // Shorter names/aliases; to easier see/check what is being initialized here.

            let v: LifeCellGridView? = cellGridView
            let s: Settings?         = settings
            let d: Settings          = Settings.Defaults

            // Life Game specific properties.

            self.activeColor     = s?.activeColor    ?? v?.activeColor   ?? d.activeColor
            self.inactiveColor   = s?.inactiveColor  ?? v?.inactiveColor ?? d.inactiveColor

            // CellGridView base class specific properties.

            super.init(viewBackground: s?.viewBackground ?? v?.viewBackground ?? d.viewBackground,
                       viewScaling:    s?.viewScaling    ?? v?.viewScaling    ?? d.viewScaling,
                       cellSize:       s?.cellSize       ?? v?.cellSize       ?? d.cellSize,
                       cellPadding:    s?.cellPadding    ?? v?.cellPadding    ?? d.cellPadding)

        }
    }
}

// FILE: ios-lifegame/LifeCellGridView.swift
//
public class LifeCellGridView: CellGridView {

    public private(set) var activeColor: Colour
    public private(set) var inactiveColor: Colour

    // Note that this constructor does in fact effectively hide the base
    // class constructor which takes a CellGridView.Config, which is what we want;
    // i.e. only allow creation of LifeCellGridView with a LifeCellGridView.Config.
    //
    public init(_ config: LifeCellGridView.Config? = nil) {
        let config: LifeCellGridView.Config = config ?? LifeCellGridView.Config()
        self.activeColor   = config.activeColor
        self.inactiveColor = config.inactiveColor
        super.init(config)
    }

    public override var config: LifeCellGridView.Config {
        LifeCellGridView.Config(self)
    }

    public override func initialize(_ config: CellGridView.Config, fit: Bool = false, center: Bool = false) {
        super.initialize(config, fit: fit, center: center)
    }

    public override func configure(_ config: CellGridView.Config) {
        if let config: LifeCellGridView.Config = config as? LifeCellGridView.Config {
            self.activeColor = config.activeColor
            self.inactiveColor = config.inactiveColor
            super.configure(config)
        }
    }
}

// FILE: ios-lifegame/ContentView.swift
//
public class ContentView
{
    /* @EnvironmentObject */ private var settings: Settings = Settings()
    /* @EnvironmentObject */ private var cellGridView: LifeCellGridView = LifeCellGridView()
    /* @State */             private var showSettingsView = false

    internal func gotoSettingsView() {
        let config: LifeCellGridView.Config = self.cellGridView.config
        self.settings.fromConfig(config)
        self.showSettingsView = true
    }

    internal func onSettingsChange() {
        let config: LifeCellGridView.Config = self.settings.toConfig(self.cellGridView)
        self.cellGridView.configure(config)
        self.showSettingsView = true
    }
}

// Testing ..
//
extension ContentView
{
    func printSettingsDefaults() {
        print()
        print("Settings.Defaults.viewBackground: \(Settings.Defaults.viewBackground)")
        print("Settings.Defaults.viewScaling: \(Settings.Defaults.viewScaling)")
        print("Settings.Defaults.cellSize: \(Settings.Defaults.cellSize)")
        print("Settings.Defaults.cellPadding: \(Settings.Defaults.cellPadding)")
        print("Settings.Defaults.activeColor: \(Settings.Defaults.activeColor)")
        print("Settings.Defaults.inactiveColor: \(Settings.Defaults.inactiveColor)")
    }

    func printSettings() {
        print()
        print("settings.viewBackground: \(self.settings.viewBackground)")
        print("settings.viewScaling: \(self.settings.viewScaling)")
        print("settings.cellSize: \(self.settings.cellSize)")
        print("settings.cellPadding: \(self.settings.cellPadding)")
        print("settings.activeColor: \(self.settings.activeColor)")
        print("settings.inactiveColor: \(self.settings.inactiveColor)")
    }

    func printCellGridViewProperties() {
        print()
        print("cellGridView.viewBackground: \(self.cellGridView.viewBackground)")
        print("cellGridView.viewScaling: \(self.cellGridView.viewScaling)")
        print("cellGridView.cellSize: \(self.cellGridView.cellSize)")
        print("cellGridView.cellPadding: \(self.cellGridView.cellPadding)")
        print("cellGridView.activeColor: \(self.cellGridView.activeColor)")
        print("cellGridView.inactiveColor: \(self.cellGridView.inactiveColor)")
    }

    func printCellGridViewConfig() {
        print()
        print("cellGridView.config.viewBackground: \(self.cellGridView.config.viewBackground)")
        print("cellGridView.config.viewScaling: \(self.cellGridView.config.viewScaling)")
        print("cellGridView.config.cellSize: \(self.cellGridView.config.cellSize)")
        print("cellGridView.config.cellPadding: \(self.cellGridView.config.cellPadding)")
        print("cellGridView.config.activeColor: \(self.cellGridView.config.activeColor)")
        print("cellGridView.config.inactiveColor: \(self.cellGridView.config.inactiveColor)")
    }

    func printSettingsToConfig() {
        print()
        print("settings.toConfig(cellGridView).viewBackground: \(self.settings.toConfig(cellGridView).viewBackground)")
        print("settings.toConfig(cellGridView).viewScaling: \(self.settings.toConfig(cellGridView).viewScaling)")
        print("settings.toConfig(cellGridView).cellSize: \(self.settings.toConfig(cellGridView).cellSize)")
        print("settings.toConfig(cellGridView).cellPadding: \(self.settings.toConfig(cellGridView).cellPadding)")
        print("settings.toConfig(cellGridView).activeColor: \(self.settings.toConfig(cellGridView).activeColor)")
        print("settings.toConfig(cellGridView).inactiveColor: \(self.settings.toConfig(cellGridView).inactiveColor)")
    }

    func simulateSettingsViewChanges() {
        self.settings.viewBackground = 990
        self.settings.viewScaling = false
        self.settings.activeColor = 991
    }

    func test() {

        print("\nINITIAL:")

        self.printSettingsDefaults()
        self.printSettings()
        self.printCellGridViewProperties()
        self.printCellGridViewConfig()
        self.printSettingsToConfig()

        self.gotoSettingsView()
        self.simulateSettingsViewChanges()
        self.onSettingsChange()

        print("\nAFTER SIMULATE SETTINGS VIEW CHANGES:")

        self.printSettings()
        self.printCellGridViewProperties()
        self.printCellGridViewConfig()
        self.printSettingsToConfig()

        /*
        print()
        self.cellGridView.configure(config)
        print(config.cellSize)
        print(config.activeColor)
        */
    }
}

let contentView: ContentView = ContentView()
contentView.test()
