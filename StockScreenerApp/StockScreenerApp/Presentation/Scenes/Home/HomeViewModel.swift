import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var recentStocks: [Stock] = []
    @Published var greeting: String = "Good Morning"
    @Published var isLoading: Bool = false
    
    private let recentlyViewedManager = RecentlyViewedManager.shared
    
    struct MarketIndex {
        let name: String
        let symbol: String
        let price: String
        let change: String
        let changePercent: String
        let isPositive: Bool
    }
    
    struct TopMover {
        let stock: Stock
        let price: String
        let change: String
        let changePercent: String
        let isPositive: Bool
    }
    
    init() {
        updateGreeting()
        loadRecentStocks()
    }
    
    func loadRecentStocks() {
        do {
            recentStocks = try recentlyViewedManager.getAll()
        } catch {
            recentStocks = []
        }
    }
    
    func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            greeting = "Good Morning"
        case 12..<17:
            greeting = "Good Afternoon"
        case 17..<24:
            greeting = "Good Evening"
        default:
            greeting = "Hello"
        }
    }
    
    func getMarketIndices() -> [MarketIndex] {
        return [
            MarketIndex(
                name: "S&P 500",
                symbol: "^GSPC",
                price: "5,825.91",
                change: "+24.85",
                changePercent: "+0.43%",
                isPositive: true
            ),
            MarketIndex(
                name: "NASDAQ",
                symbol: "^IXIC",
                price: "18,489.55",
                change: "+123.45",
                changePercent: "+0.67%",
                isPositive: true
            ),
            MarketIndex(
                name: "DOW JONES",
                symbol: "^DJI",
                price: "43,275.91",
                change: "-88.15",
                changePercent: "-0.20%",
                isPositive: false
            )
        ]
    }
    
    func getTopMovers() -> [TopMover] {
        let movers = [
            ("AAPL", "Apple Inc.", "+1.24%", "+2.15"),
            ("TSLA", "Tesla, Inc.", "+3.87%", "+8.42"),
            ("NVDA", "NVIDIA Corporation", "-0.52%", "-2.10"),
            ("MSFT", "Microsoft Corporation", "+0.89%", "+3.25")
        ]
        
        return movers.map { symbol, name, percent, change in
            let isPositive = !percent.hasPrefix("-")
            let price = String(format: "$%.2f", Double.random(in: 100...500))
            
            return TopMover(
                stock: Stock(symbol: symbol, name: name, type: "Equity", region: "United States"),
                price: price,
                change: change,
                changePercent: percent,
                isPositive: isPositive
            )
        }
    }
}
