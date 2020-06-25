//
//  sqwidget.swift
//  sqwidget
//
//  Created by Aryan Nambiar on 6/22/20.
//

import WidgetKit
import SwiftUI
import CoreData

let defaultImageColors = UIImageColors(background: UIColor.black, primary: UIColor.white, secondary: UIColor.blue, detail: UIColor.purple)

struct PlaceholderView : View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Now Playing")
                .font(.system(.title3))
                .foregroundColor(.black)
            Text("Please login on app!")
                .font(.system(.subheadline))
                .foregroundColor(.black)
                .bold()
            Text("by Artist\nReleased:01/01/0000")
                .font(.system(.caption))
                .foregroundColor(.black)
            Text("Updated at \(Date())")
                .font(.system(.caption2))
                .foregroundColor(.black)
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
        .padding()
        .background(Color.black)
        .animation(.easeInOut)
//            .background(LinearGradient(gradient: Gradient(colors: [.orange, .red]), startPoint: .top, endPoint: .bottom))
    }
}

struct NowPlayingCheckerWidgetView : View {
    let entry: LastNowPlayingEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Now Playing")
                .font(.system(.title3))
                .foregroundColor(Color(entry.NowPlaying.imageColors.primary))
            Text(entry.NowPlaying.message)
                .font(.system(.subheadline))
                .foregroundColor(Color(entry.NowPlaying.imageColors.primary))
                .bold()
            Text("by \(entry.NowPlaying.author)")
                .font(.system(.caption))
                .foregroundColor(Color(entry.NowPlaying.imageColors.primary))
            Text("Released: \(entry.NowPlaying.date)")
                .font(.system(.caption))
                .foregroundColor(Color(entry.NowPlaying.imageColors.secondary))
            Text("Updated at \(Self.format(date:entry.date))")
                .font(.system(.caption2))
                .foregroundColor(Color(entry.NowPlaying.imageColors.detail))
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
        .padding()
        .background(Color(entry.NowPlaying.imageColors.background))
        .animation(.easeInOut)
//            .background(LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .top, endPoint: .bottom))
    }

    static func format(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct NowPlaying {
    let message: String
    let author: String
    let date: String
    let imageColors: UIImageColors
}

var in_progress = false

var recent_NowPlaying: NowPlaying = NowPlaying(message: "Song", author: "Artist", date: "2020-06-23", imageColors: defaultImageColors)

struct NowPlayingLoader {
    static func fetch(completion: @escaping (Result<NowPlaying, Error>) -> Void) {
        if !in_progress {
            in_progress = true
            let currentPlaybackURL = URL(string: "https://api.spotify.com/v1/me/player")!
            var currentPlaybackRequest = URLRequest(url: currentPlaybackURL)
            
            let defaults = UserDefaults(suiteName: "group.dev.nambiar.CustomWidgets.app")!
            var accessToken = defaults.string(forKey: "accessToken")
            
            if(accessToken != nil) {
                accessToken = accessToken!
                
                currentPlaybackRequest.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")

                let task = URLSession.shared.dataTask(with: currentPlaybackRequest) { (data, response, error) in
                    guard error == nil else {
                        completion(.failure(error!))
                        return
                    }
                    let NowPlaying = getNowPlayingInfo(fromData: data!)
                    completion(.success(NowPlaying))

                    recent_NowPlaying = NowPlaying
                    in_progress = false
                }
                task.resume()
                
            }
        }

        else {
            completion(.success(recent_NowPlaying))
        }
    }

    static func getNowPlayingInfo(fromData data: Foundation.Data) -> NowPlaying {
        let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        var songName = ""
        var artistName = ""
        var date = ""
        var colors = defaultImageColors
        
        if (json != nil) {
            let itemJSON: [String: Any]? = json!["item"] as? [String: Any]
            
            if(itemJSON != nil) {
                
                let albumJSON = itemJSON!["album"] as! [String: Any]

                songName = itemJSON!["name"] as! String
                date = albumJSON["release_date"] as! String
                let artists = itemJSON!["artists"] as! Array<Any>

                let artist = artists[0] as! [String: Any]
                artistName = artist["name"] as! String
                
                let images = albumJSON["images"] as! Array<Any>
                let imageJSON = images[0] as! [String: Any]
                let url = imageJSON["url"] as! String
                
                colors = getImageColors(url: URL(string: url)!)
            }
            
            else {
                print("INVALID JSON")
            }
        }

        return NowPlaying(message: songName, author: artistName, date: date, imageColors: colors)
    }
}

func getImageColors(url: URL) -> UIImageColors {
    let imageData = try? Data(contentsOf: url)
    
    if(imageData != nil) {
        let colors = UIImage(data: imageData!)!.getColors()
        
        return colors!
    }
    else {
        return defaultImageColors
    }
}

var currentNowPlaying: NowPlaying = NowPlaying(message: "Song", author: "Artist", date: "2020-06-24", imageColors: defaultImageColors)
var newRefreshDate: Date = Date()

var initialized: Bool = false

struct NowPlayingTimeline: TimelineProvider {
    typealias Entry = LastNowPlayingEntry
    /* protocol methods implemented below! */
    public func snapshot(with context: Context, completion: @escaping (LastNowPlayingEntry) -> ()) {
        let fakeNowPlaying = NowPlaying(message: "Fixed stuff", author: "John Appleseed", date: "2020-06-23", imageColors: defaultImageColors)
        let entry = LastNowPlayingEntry(date: Date(), NowPlaying: fakeNowPlaying)
        completion(entry)
    }

    public func timeline(with context: Context, completion: @escaping (Timeline<LastNowPlayingEntry>) -> ()) {

        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .second, value: 10, to: currentDate)!
        
        if (currentDate >= newRefreshDate) || !initialized {
            initialized = true
            newRefreshDate = refreshDate

            NowPlayingLoader.fetch { result in
                let nowplaying: NowPlaying
                if case .success(let fetchedNowPlaying) = result {
                    nowplaying = fetchedNowPlaying
                } else {
                    nowplaying = NowPlaying(message: "Failed to load Now Playing", author: "", date: "", imageColors: defaultImageColors)
                }
                let entry = LastNowPlayingEntry(date: currentDate, NowPlaying: nowplaying)
                let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
                currentNowPlaying = nowplaying
                
                completion(timeline)
            }
        }
        
        else {
            let entry = LastNowPlayingEntry(date: currentDate, NowPlaying: currentNowPlaying)
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        }
        
    }
}

struct LastNowPlayingEntry: TimelineEntry {
    public let date: Date
    public let NowPlaying: NowPlaying
}

@main
struct NowPlayingCheckerWidget: Widget {
    private let kind: String = "NowPlayingCheckerWidget"

    public var body: some WidgetConfiguration {

        StaticConfiguration(kind: kind, provider: NowPlayingTimeline(), placeholder: PlaceholderView()) { entry in
            NowPlayingCheckerWidgetView(entry: entry)
        }
        .configurationDisplayName("Now Playing by Aryan Nambiar")
        .description("Shows your Spotify Now Playing!")
    }
}
