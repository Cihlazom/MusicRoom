//
//  Library.swift
//  MusicRoom
//
//  Created by Vladislav on 18.04.2022.
//

import SwiftUI
import URLImage

struct Library: View {
    @State var tracks = UserDefaults.standard.savedTracks()
    @State private var track: SearchViewModel.Cell!
    var tabBarDelegate: MainTabBarControllerDelegate?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                GeometryReader { geometry in
                    HStack(spacing: 20){
                        Button {
                            self.track = tracks[0]
                            let keyWindow = UIApplication.shared.connectedScenes
                                .filter({$0.activationState == .foregroundActive})
                                .map({$0 as? UIWindowScene})
                                .compactMap({$0})
                                .first?.windows
                                .filter({$0.isKeyWindow}).first
                            let tabBarVC = keyWindow?.rootViewController as? MainTabBarController
                            tabBarVC?.trackDetailView.delegate = self
                            self.tabBarDelegate?.maximizeTrackDetails(viewModel: self.track)
                        } label: {
                            Image(systemName: "play.fill")
                                .frame(width: abs(geometry.size.width/2 - 10), height: 50, alignment: .center)
                                .tint(.red)
                                .background(Color.init(uiColor: .secondarySystemBackground))
                                .cornerRadius(10)
                        }
                        
                        Button {
                            self.tracks = UserDefaults.standard.savedTracks()
                        } label: {
                            Image(systemName: "arrow.2.circlepath")
                                .frame(width: abs(geometry.size.width/2 - 10), height: 50)
                                .tint(.red)
                                .background(Color.init(uiColor: .secondarySystemBackground))
                                .cornerRadius(10)
                        }
                    }
                }.padding().frame(height: 50)
                Divider().padding(.leading).padding(.trailing)
                List{
                    ForEach(tracks) { track in
                        LibraryCell(cell: track).gesture(TapGesture().onEnded({ _ in
                            self.track = track
                            let keyWindow = UIApplication.shared.connectedScenes
                                .filter({$0.activationState == .foregroundActive})
                                .map({$0 as? UIWindowScene})
                                .compactMap({$0})
                                .first?.windows
                                .filter({$0.isKeyWindow}).first
                            let tabBarVC = keyWindow?.rootViewController as? MainTabBarController
                            tabBarVC?.trackDetailView.delegate = self
                            
                            self.tabBarDelegate?.maximizeTrackDetails(viewModel: track)
                        }))
                    }.onDelete(perform: delete)
                }.background(Color.init(uiColor: .systemBackground))
            }
            .navigationTitle("Library")
        }.navigationViewStyle(.stack)
    }
    
    func delete(at offsets: IndexSet) {
        tracks.remove(atOffsets: offsets)
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: tracks, requiringSecureCoding: false) {
            UserDefaults.standard.set(savedData, forKey: UserDefaults.favouriteTrackKey)
        }
    }
}


struct LibraryCell: View {
    var cell: SearchViewModel.Cell
    var body: some View {
        HStack {
            let url = URL(string: cell.iconUrlString ?? "")
            URLImage(url!) { image in
                image
                    .resizable()
                    .frame(width: 60, height: 60)
                    .background(.red)
            }

            VStack(alignment: .leading) {
                Text(cell.trackName)
                Text(cell.artistName)

            }

        }
    }
}

struct Library_Previews: PreviewProvider {
    static var previews: some View {
        Library()
    }
}

extension Library: TrackMovingDelegate {
    
    func moveBack() -> SearchViewModel.Cell? {
        let index = tracks.firstIndex(of: track)
        guard let myindex = index else { return nil }
        var nextTrack: SearchViewModel.Cell
        if myindex - 1 == -1 {
            nextTrack = tracks[tracks.count - 1]
        } else {
            nextTrack = tracks[myindex - 1]
        }
        self.track = nextTrack
        return nextTrack
    }
    
    func moveForward() -> SearchViewModel.Cell? {
        let index = tracks.firstIndex(of: track)
        guard let myIndex = index else { return nil }
        var nextTrack: SearchViewModel.Cell
        if myIndex + 1 == tracks.count {
            nextTrack = tracks[0]
        } else {
            nextTrack = tracks[myIndex + 1]
        }
        self.track = nextTrack
        return nextTrack
    }
}
