//
//  Event.swift
//  VLCKitSwift
//
//  Created by Alsey Coleman Miller on 10/4/17.
//  Copyright © 2017 ColemanCDA. All rights reserved.
//

import VLC

public enum EventType: libvlc_event_e.RawValue {
    
    case mediaMetaChanged=0
    case mediaSubItemAdded
    case mediaDurationChanged
    case mediaParsedChanged
    case mediaFreed
    case mediaStateChanged
    case mediaSubItemTreeAdded
    
    case mediaPlayerMediaChanged=0x100
    case mediaPlayerNothingSpecial
    case mediaPlayerOpening
    case mediaPlayerBuffering
    case mediaPlayerPlaying
    case mediaPlayerPaused
    case mediaPlayerStopped
    case mediaPlayerForward
    case mediaPlayerBackward
    case mediaPlayerEndReached
    case mediaPlayerEncounteredError
    case mediaPlayerTimeChanged
    case mediaPlayerPositionChanged
    case mediaPlayerSeekableChanged
    case mediaPlayerPausableChanged
    case mediaPlayerTitleChanged
    case mediaPlayerSnapshotTaken
    case mediaPlayerLengthChanged
    case mediaPlayerVout
    case mediaPlayerScrambledChanged
    case mediaPlayerESAdded
    case mediaPlayerESDeleted
    case mediaPlayerESSelected
    case mediaPlayerCorked
    case mediaPlayerUncorked
    case mediaPlayerMuted
    case mediaPlayerUnmuted
    case mediaPlayerAudioVolume
    case mediaPlayerAudioDevice
    case mediaPlayerChapterChanged
    
    case mediaListItemAdded=0x200
    case mediaListWillAddItem
    case mediaListItemDeleted
    case mediaListWillDeleteItem
    case mediaListEndReached
    
    case mediaListViewItemAdded=0x300
    case mediaListViewWillAddItem
    case mediaListViewItemDeleted
    case mediaListViewWillDeleteItem
    
    case mediaListPlayerPlayed=0x400
    case mediaListPlayerNextItemSet
    case mediaListPlayerStopped
    
    case mediaDiscovererStarted=0x500
    case mediaDiscovererEnded
    
    case rendererDiscovererItemAdded
    case rendererDiscovererItemDeleted
    
    case vlmMediaAdded=0x600
    case vlmMediaRemoved
    case vlmMediaChanged
    case vlmMediaInstanceStarted
    case vlmMediaInstanceStopped
    case vlmMediaInstanceStatusInit
    case vlmMediaInstanceStatusOpening
    case vlmMediaInstanceStatusPlaying
    case vlmMediaInstanceStatusPause
    case vlmMediaInstanceStatusEnd
    case vlmMediaInstanceStatusError
}

extension EventType: VLCEnumeration {
    
    public typealias VLCType = libvlc_event_e
}

internal extension libvlc_event_type_t {
    
    init(_ event: EventType) {
        
        self.init(event.rawValue)
    }
}
