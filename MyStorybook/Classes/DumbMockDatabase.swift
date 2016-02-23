//
//  DumbMockDatabase.swift
//  MyStorybook
//
//  Created by David Paul Quesada on 2/18/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import Foundation

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
    
    db.createStoryWithPages(ms("Sports!", "soccerball",
        mp(1, "sports1"),
        mp(2, "sports2"),
        mp(3, "sports3")))
    
    db.createStoryWithPages(ms("Food", "pizza",
        mp(1, "food1"),
        mp(2, "food2"),
        mp(3, "food3"),
        mp(4, "food4"),
        mp(5, "food5")))
    
    db.createStoryWithPages(ms("Other?", "somethingElse",
        mp(1, "other1"),
        mp(2, "other2")))
    
    return db
}