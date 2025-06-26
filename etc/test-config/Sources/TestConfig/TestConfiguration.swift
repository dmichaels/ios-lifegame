// ---------------------------------------------------------------------------------------------------------------------
// ios-cellgridview
// ---------------------------------------------------------------------------------------------------------------------

// FILE: ios-cellgridview/CellGridView+Defaults.swift
//
extension CellGridView
{
    public class Defaults {
        public static let viewBackground: Int     = 123
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

        public var viewBackground: Int
        public var viewTransparency: UInt8
        public var viewScaling: Bool
        public var cellSize: Int
        public var cellPadding: Int

        // Initializes this instance of CellGridView.Config with the properties from the given
        // CellGridView, or with the default values from CellGridView.Defaults is nil is given.
        //
        public init(_ cellGridView: CellGridView? = nil) {
            self.viewBackground   = cellGridView?.viewBackground   ?? CellGridView.Defaults.viewBackground
            self.viewTransparency = cellGridView?.viewTransparency ?? CellGridView.Defaults.viewTransparency
            self.viewScaling      = cellGridView?.viewScaling      ?? CellGridView.Defaults.viewScaling
            self.cellSize         = cellGridView?.cellSize         ?? CellGridView.Defaults.cellSize
            self.cellPadding      = cellGridView?.cellPadding      ?? CellGridView.Defaults.cellPadding
        }
    }
}

// FILE: ios-cellgridview/CellGridView.swift
//
public class CellGridView
{
    public private(set) var viewBackground: Int
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
        //
        // TODO: Should I do the CellGridView.Config.init thing right here directly instead?
        // Question is who properly should know how exactly to create CellGridView.Config instance?
        //
        CellGridView.Config(self)
    }

    open func initialize(_ config: CellGridView.Config, fit: Bool = false, center: Bool = false) {
        self.configure(config)
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
    public var viewBackground: Int = CellGridView.Defaults.viewBackground
    public var viewScaling: Bool   = CellGridView.Defaults.viewScaling
    public var cellSize: Int       = 25
    public var cellPadding: Int    = 1
    public var activeColor: Int    = 0x06
    public var inactiveColor: Int  = 0x07

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

        public var activeColor: Int
        public var inactiveColor: Int

        // Initializes this instance of LifeCellGridView.Config with the properties from the given
        // Settings, or if this is nil, then with the properties from the given LifeCellGridView,
        // or if that is nil, then from the default values in Settings.Defaults.
        //
        // Note that this constructor does in fact effectively hide the base
        // class constructor which takes a CellGridView, which is what we want;
        // i.e. only allow creation of LifeCellGridView.Config with a LifeCellGridView.
        //
        // Note that calling this with a Settings object is from the toConfig method of
        // LifeCellGridView.Config. We do not just initialize from Settings directly there
        // because we need to initialize its CellGridView base class properties, particularly
        // those base properties which we are not interested in here.
        //
        internal init(_ cellGridView: LifeCellGridView? = nil, _ settings: Settings? = nil) {

            // Shorter names/aliases; to easier see/check what is being initialized here.

            let v: LifeCellGridView? = cellGridView
            let s: Settings?         = settings
            let d: Settings          = Settings.Defaults

            // Life Game specific properties.

            self.activeColor     = s?.activeColor    ?? v?.activeColor   ?? d.activeColor
            self.inactiveColor   = s?.inactiveColor  ?? v?.inactiveColor ?? d.inactiveColor

            // CellGridView base class specific properties.

            super.init(v)

            super.viewBackground = s?.viewBackground ?? v?.viewBackground ?? d.viewBackground
            super.viewScaling    = s?.viewScaling    ?? v?.viewScaling    ?? d.viewScaling
            super.cellSize       = s?.cellSize       ?? v?.cellSize       ?? d.cellSize
            super.cellPadding    = s?.cellPadding    ?? v?.cellPadding    ?? d.cellPadding
        }
    }
}

// FILE: ios-lifegame/LifeCellGridView.swift
//
public class LifeCellGridView: CellGridView {

    public private(set) var activeColor: Int
    public private(set) var inactiveColor: Int

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
        self.configure(config)
    }

    public override func configure(_ config: CellGridView.Config) {
        if let config: LifeCellGridView.Config = config as? LifeCellGridView.Config {
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
