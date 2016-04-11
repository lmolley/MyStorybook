//
//  DumbMockDatabase.swift
//  MyStorybook
//
//  Created by David Paul Quesada on 2/18/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import Foundation
import Photos // For simple database import from moments

class DumbMockDatabase : Database
{
    internal var stories: [Story] = []
    internal var pages: [Int: [Page]] = [:]
    
    private var storyId = 1
    private var pageId = 1
    
    func getStories() -> [Story]
    {
        return self.stories
    }
    
    func getPages(storyId: Int) -> [Page]?
    {
        return self.pages[storyId]?.sort({ $0.number < $1.number })
    }
    
    func createStory(story: Story)
    {
        // Don't add multiple stories with the same Id.
        self.stories.append(story)
        story.id = self.storyId
        self.storyId += 1
        
        self.pages[story.id] = story.pages ?? [Page]()
    }
    
    func createPage(page: Page)
    {
        guard var pageList = self.pages[page.storyId] else
        {
            // The database doesn't have a story with the given ID to append this page to.
            return
        }
        
        pageList.append(page)
        page.id = self.pageId
        self.pageId += 1
    }

    func removeStory(sId: Int)
    {
        stories = stories.filter { $0.id != sId }
    }

    func removePage(pId: Int)
    {
        for (sid, pageList) in pages {
            pages[sid] = pageList.filter { $0.id != pId }
        }
    }
}

func SampleDumbMockDatabase() -> Database
{
    let db: Database = DumbMockDatabase()
    
    func ms(title: String, _ icon: String, _ pages: Page...) -> Story
    {
        let story = Story()
        story.title = title
        story.icon = icon
        story.pages = pages
        return story
    }
    
    func mp(number: Int, _ photoId: String) -> Page
    {
        let page = Page()
        page.number = number
        page.photoId = photoId
        return page
    }
    
    db.createStoryWithPages(ms("Party", "pizza",
        mp(1, "967B1CE1-D4D5-4755-8BE8-6330C151A74A/L0/001"),
        mp(2, "C2D31558-B30D-445A-9C59-4C27F8049C9B/L0/001"),
        mp(3, "2B654ABA-3F67-45A1-9598-941AF7F8C782/L0/001"),
        mp(4, "4CD71961-F24E-49C0-9AAF-F10A58B04504/L0/001")))
    
    db.createStoryWithPages(ms("Selena!", "ic_sentiment_satisfied_black_48dp",
        mp(1, "5F4EFFC2-BF60-45A5-8C35-371AE7DED242/L0/001"),
        mp(2, "3FC2AE86-3105-43A6-8DFE-9180E159EFA9/L0/001"),
        mp(3, "DF490728-6BD7-4BDB-A5F1-991770DA4EA2/L0/001"),
        mp(4, "FA4A1B53-44E8-49F4-8F09-D7361FA4C12F/L0/001")))
    
    
    db.createStoryWithPages(ms("Other?", "somethingElse",
        mp(1, "other1"),
        mp(2, "other2")))
    
    return db
}

func ImportMomentsToDatabase(db: Database)
{
    func ms(title: String, _ icon: String, _ pages: Page...) -> Story
    {
        let story = Story()
        story.title = title
        story.icon = icon
        story.pages = pages
        return story
    }
    
    func mp(number: Int, _ photoId: String) -> Page
    {
        let page = Page()
        page.number = number
        page.photoId = photoId
        return page
    }
    
    
    let collectionFetchOptions = PHFetchOptions()
    collectionFetchOptions.sortDescriptors = [NSSortDescriptor(key:"startDate", ascending: false)]
    collectionFetchOptions.fetchLimit = 15
    let smartAlbums = PHAssetCollection.fetchAssetCollectionsWithType(.Moment, subtype: .Any, options: collectionFetchOptions)
    smartAlbums.enumerateObjectsUsingBlock({
        if let collection = $0.0 as? PHAssetCollection {
            
            let story = Story()
            story.title = collection.localizedTitle ?? "Untitled!!!"
            story.icon = ""
            story.pages = []
            
            let assets = PHAsset.fetchAssetsInAssetCollection(collection, options: nil)
            assets.enumerateObjectsUsingBlock({ (someObject, index, _) -> Void in
                let asset = someObject as! PHAsset
                
                let page = mp(index, asset.localIdentifier)
                story.pages!.append(page)
                
                if story.icon == "" {
                    story.icon = asset.localIdentifier
                }
            })
            
        
            db.createStoryWithPages(story)
        }
    })
}