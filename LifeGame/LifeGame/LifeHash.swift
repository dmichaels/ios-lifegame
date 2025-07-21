import CryptoKit
import Foundation
import CellGridView

extension LifeCellGridView
{
    internal func lifehash(_ settings: Settings)
    {
        var cellsActive: Set<CellLocation> = LifeCellGridView.sha256As16x16CellLocations(settings.lifehashValue)
        let generationsMax: Int = 64
        var generationSignatures: [[UInt64]] = []

        func generationSignatureSeen(_ generationSignature: [UInt64]) -> Bool {
            for signature in generationSignatures {
                if (signature == generationSignature) {
                    return true
                }
            }
            return false
        }

        let ncolumns: Int = 16
        let nrows: Int = 16

        for _ in 0..<generationsMax {
            let cellsActiveNextGeneration: Set<CellLocation> = LifeCellGridView.nextGeneration(
                cellsActive: cellsActive, ncolumns: ncolumns, nrows: nrows,
                variantOverPopulate: self.variantOverPopulate, variantHighLife: self.variantHighLife)
            if (cellsActiveNextGeneration.count == 0) {
                break
            }
            let generationSignature: [UInt64] = LifeCellGridView.signature(cellsActiveNextGeneration)
            if (generationSignatureSeen(generationSignature)) {
                break
            }
            generationSignatures.append(generationSignature)
            cellsActive = cellsActiveNextGeneration
        }

        let ncolumnsSymmetrized: Int = ncolumns * 2
        let nrowsSymmetrized: Int = nrows * 2
        cellsActive = LifeCellGridView.symmetrize(cellsActive)

        self.automationStop()
        self.erase()

        settings.fromConfig(self)
        settings.gameMode = GameMode.lifehash
        settings.automationMode = false
        settings.gridColumns = ncolumns * 2
        settings.gridRows = nrows * 2
        settings.fit = .disabled
        settings.center = true
        settings.variantInactiveFade = false
        self.configure(settings)

        for cellLocation in cellsActive {
            if let cell: LifeCell = self.gridCell(cellLocation.x, cellLocation.y) {
                cell.select()
            }
        }

        self.updateImage()
    }

    internal static func nextGeneration(cellsActive: Set<CellLocation>,
                                        ncolumns: Int,
                                        nrows: Int,
                                        variantOverPopulate: Bool = false,
                                        variantHighLife: Bool = false) -> Set<CellLocation>
    {
        var cellsActiveNew: Set<CellLocation> = []
        var neighbors: [CellLocation: Int] = [:]

        // Count neighbors for all live cells and their neighbors.

        for cellLocation in cellsActive {
            //
            // This loops through the cells that are currently active, collecting
            // the neighbors of each, and the neighbor counts of each/all of these.
            //
            for dy in -1...1 {
                for dx in -1...1 {
                    if ((dx == 0) && (dy == 0)) { continue }
                    let neighborLocation = CellLocation(
                        (cellLocation.x + dx + ncolumns) % ncolumns,
                        (cellLocation.y + dy + nrows)    % nrows
                    )
                    neighbors[neighborLocation, default: 0] += 1
                }
            }
        }

        // Determine which cells survive, die, or are born in the next generation.

        for (cellLocation, count) in neighbors {
            if (cellsActive.contains(cellLocation)) {
                //
                // Survival rules; i.e. cells that were active and are to remain active.
                //
                if ((count == 2) || (count == 3)) {
                    cellsActiveNew.insert(cellLocation)
                }
                else if (variantOverPopulate && (count > 3)) {
                    cellsActiveNew.insert(cellLocation)
                }
            }
            else {
                //
                // Birth rule; i.e. cells that were inactive but are to become active;
                // note that death rule falls out as we a populating a new set of live cells.
                //
                if (count == 3) {
                    cellsActiveNew.insert(cellLocation)
                }
                else if (variantHighLife && (count == 6)) {
                    cellsActiveNew.insert(cellLocation)
                }
            }
        }

        return cellsActiveNew
    }

    public static func sha256As16x16CellLocations(_ input: String, ncolumns: Int = 16) -> Set<CellLocation>
    {
        let hash: SHA256Digest = SHA256.hash(data: Data(input.utf8))
        var cellLocations: Set<CellLocation> = []
        for (byteIndex, byte) in hash.enumerated() {
            for bit in 0..<8 {
                let bitIndex = byteIndex * 8 + (7 - bit)  // msb first
                if (byte & (1 << bit)) != 0 {
                    let x: Int = bitIndex % ncolumns
                    let y: Int = bitIndex / ncolumns
                    cellLocations.insert(CellLocation(x, y))
                }
            }
        }
        return cellLocations
    }

    // Returns the "signature" of the grid of ncolumns and nrows, i.e where each active/unique cell (location)
    // is uniquely identified by the given cellsActive CellLocation values; the results of this, on different
    // cell (active/inactive) configurations, can be directly compared to each other to see if they are the same.
    //
    internal static func signature(_ cellsActive: Set<CellLocation>, ncolumns: Int = 16, nrows: Int = 16) -> [UInt64]
    {
        var signature: [UInt64] = []
        var current: UInt64 = 0
        var index: Int = 0
        for cellIndex in 0..<(ncolumns * nrows) {
            let cellLocation: CellLocation = CellLocation(cellIndex % ncolumns, cellIndex / ncolumns)
            if (cellsActive.contains(cellLocation)) {
                current |= (1 << index)
            }
            index += 1
            if (index == 64) {
                signature.append(current)
                current = 0
                index = 0
            }
        }
        if (index > 0) {
            signature.append(current)
        }
        return signature
    }

    internal static func toHex(_ signature: [UInt64]) -> String {
        return signature.map { String(format: "%016llx", $0) }.joined()
    }

    internal static func symmetrize(_ cellsActive: Set<CellLocation>, ncolumns: Int = 16, nrows: Int = 16) -> Set<CellLocation>
    {
        var activeCellsOutput: Set<CellLocation> = cellsActive
        let ncolumnsOutput: Int = ncolumns * 2
        let nrowsOutput: Int = nrows * 2
        for cellLocation in cellsActive {
            activeCellsOutput.insert(CellLocation(ncolumnsOutput - cellLocation.x - 1, cellLocation.y))
            activeCellsOutput.insert(CellLocation(cellLocation.x, nrowsOutput - cellLocation.y - 1))
            activeCellsOutput.insert(CellLocation(ncolumnsOutput - cellLocation.x - 1, nrowsOutput - cellLocation.y - 1))
        }
        return activeCellsOutput
    }
}
