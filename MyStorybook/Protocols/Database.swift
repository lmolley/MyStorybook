//
//  Database.swift
//  MyStorybook
//
//  Created by David Paul Quesada on 2/18/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//


protocol Database
{
    /// Gets all the stories in the database.
    func getStories() -> [Story]
    
    /// Gets all the pages associated with a story whose ID is given.
    /// - parameter storyId: The ID of the story whose pages to get.
    /// - returns: An array of pages, or nil if there is no story with the given ID.
    func getPages(storyId: Int) -> [Page]?
    
    /// Adds the given Story to the database and updates the 'id' property of the Story object.
    /// - parameter story: The Story object to add to the database.
    func createStory(story: Story)
    
    /// Adds the given Page to the database and updates the 'id' property of the Page object.
    /// - parameter page: The Page object to add to the database.
    func createPage(page: Page)
    
    /// Deletes a story from the database.
    /// - parameter sId: The ID of the story to delete.
    func removeStory(sId: Int)
    
    /// Deletes a page from the database.
    /// - parameter pId: The ID of the page to delete.
    func removePage(pId: Int)
}

extension Database
{
    /// Adds a story (and all of the pages in its 'pages' property) to the database, updating
    /// the 'id' property of the story and its Page objects.
    func createStoryWithPages(story: Story)
    {
        self.createStory(story)
        
        for page in story.pages!
        {
            page.storyId = story.id
            self.createPage(page)
        }
    }
}