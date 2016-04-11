//
//  MyStorybookDatabase.swift
//  MyStorybook
//
//  Created by Nicholas Orlando on 2/23/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import Foundation
import UIKit

class MyStorybookDatabase : Database {
    var databasePath = NSString()
    
    internal var stories: [Story] = []
    //internal var pages: [Page] = []
    
    func getStories() -> [Story]
    {
        let contactDB = FMDatabase(path: databasePath as String)
        
        if contactDB.open()
        {
            let querySQL = "SELECT * FROM STORYBOOKS"
            
            let results:FMResultSet? = contactDB.executeQuery(querySQL, withArgumentsInArray: nil)
            
            
            while results?.next() == true
            {
                let newStory = Story()
                if let storyIcon = results?.stringForColumn("icon")
                {
                    newStory.icon = storyIcon
                }
                if let storyTitle = results?.stringForColumn("title")
                {
                    newStory.title = storyTitle
                }
                if let curStoryId = results?.intForColumn("id")
                {
                    newStory.id = Int(curStoryId)
                }
                
                self.stories.append(newStory)
            }
        }
        
        contactDB.close()
        
        return self.stories
    }
    
    func getPages(storyId: Int) -> [Page]?
    {
        let contactDB = FMDatabase(path: databasePath as String)
        var pages = [Page]()
        
        if contactDB.open()
        {
            let querySQL = "SELECT * FROM PAGES WHERE bookid = ?;"
            
            let results:FMResultSet! = contactDB.executeQuery(querySQL, withArgumentsInArray: [storyId])
            
            while results.next()
            {
                let newPage = Page()
                if let pageId = results?.intForColumn("id")
                {
                    newPage.id = Int(pageId)
                }
                if let pageNumber = results?.intForColumn("sequencenumber")
                {
                    newPage.number = Int(pageNumber)
                }
                if let pagePhotoId = results?.stringForColumn("photolibraryid")
                {
                    newPage.photoId = pagePhotoId
                }
                if let pageFrameId = results?.stringForColumn("frameid")
                {
                    newPage.frameId = pageFrameId
                }
                if let pageFilterId = results?.stringForColumn("filterid")
                {
                    newPage.filterId = pageFilterId
                }
                newPage.storyId = storyId
                
                //Fetch emojis for page
                let queryEmojiSQL = "SELECT * FROM EMOJIS WHERE pageid = ?;"
                
                let emojiResults:FMResultSet! = contactDB.executeQuery(queryEmojiSQL, withArgumentsInArray: [newPage.id])
                
                while emojiResults.next()
                {
                    let newEmoji = Emoji()
                    if let id = emojiResults?.intForColumn("id")
                    {
                        newEmoji.id = Int(id)
                    }
                    if let emojiId = emojiResults?.intForColumn("emojiid")
                    {
                        newEmoji.id = Int(emojiId)
                    }
                    if let x = emojiResults?.intForColumn("xcoord")
                    {
                        newEmoji.x = Int(x)
                    }
                    if let y = emojiResults?.intForColumn("ycoord")
                    {
                        newEmoji.y = Int(y)
                    }
                    if let z = emojiResults?.intForColumn("zcoord")
                    {
                        newEmoji.z = Int(z)
                    }
                    
                    newPage.emojis.append(newEmoji)
                }
                
                pages.append(newPage)
            }
        }
        
        contactDB.close()
        
        return pages
    }
    
    func createStory(story: Story)
    {
        let contactDB = FMDatabase(path: databasePath as String)
        
        if contactDB.open()
        {
            let insertSQL = "INSERT INTO STORYBOOKS (icon, title) VALUES ('\(story.icon)', '\(story.title)')"
            
            let result = contactDB.executeUpdate(insertSQL, withArgumentsInArray: nil)
            
            if !result
            {
                //print("Did not successfully add story to database")
                print("Error: \(contactDB.lastErrorMessage())")
            }
            else
            {
                //print("Successfully added story to database")
                story.id = Int(contactDB.lastInsertRowId())
            }
        }
        contactDB.close()
    }
    
    func createPage(page: Page)
    {
        let contactDB = FMDatabase(path: databasePath as String)
        
        if contactDB.open()
        {
            let insertSQL = "INSERT INTO PAGES (photolibraryid, sequencenumber, frameid, filterid, bookid) VALUES ('\(page.photoId)', '\(page.number)', '\(page.frameId)', '\(page.filterId)', '\(page.storyId)')"
            
            let result = contactDB.executeUpdate(insertSQL, withArgumentsInArray: nil)
            
            if !result
            {
                //print("Did not successfully add page to database")
                print("Error: \(contactDB.lastErrorMessage())")
            }
            
            
        }
        contactDB.close()
        
    }
    
    func updatePage(page: Page)
    {
        let  contactDB = FMDatabase(path: databasePath as String)
        
        if contactDB.open()
        {
            //Delete emojis from page
            let deleteEmojiSQL = "DELETE FROM EMOJIS WHERE pageid = \(page.id)"
            
            let result = contactDB.executeUpdate(deleteEmojiSQL, withArgumentsInArray: nil)
            
            if !result
            {
                print("Error: \(contactDB.lastErrorMessage())")
            }
            
            //Update filters and frames
            let updateSQL = "UPDATE PAGES SET frameid = \(page.frameId), filterid = \(page.filterId) WHERE id = \(page.id)"
            
            let result1 = contactDB.executeUpdate(updateSQL, withArgumentsInArray: nil)
            
            if !result1
            {
                print("Error: \(contactDB.lastErrorMessage())")
            }
            
            
            //Add emojis to database
            for emoji in page.emojis
            {
                let insertEmojiSQL = "INSERT INTO EMOJIS (emojiid, xcoord, ycoord, zcoord, pageid) VALUES ('\(emoji.emojiId)', '\(emoji.x)', '\(emoji.y)', '\(emoji.z)', '\(emoji.pageId)')"
                
                let result2 = contactDB.executeUpdate(insertEmojiSQL, withArgumentsInArray: nil)
                
                if !result2
                {
                    print("Error: \(contactDB.lastErrorMessage())")
                }
            }
        }
        
        
    }
    
    func createDB()
    {
        let filemgr = NSFileManager.defaultManager()
        
        let dirURLs = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let fileURL = dirURLs.URLByAppendingPathComponent("MyStorybook.db")
        
        databasePath = fileURL.path!
        
        //print(databasePath)
        
        if !filemgr.fileExistsAtPath(databasePath as String)
        {
            let contactDB = FMDatabase(path: databasePath as String)
            
            if contactDB == nil
            {
                print("Error: \(contactDB.lastErrorMessage())")
            }
            
            if contactDB.open()
            {
                //Storybooks table
                let sql_stmt1 = "CREATE TABLE IF NOT EXISTS STORYBOOKS (ID INTEGER PRIMARY KEY AUTOINCREMENT, ICON TEXT, TITLE TEXT)"
                
                //Pages table
                let sql_stmt2 = "CREATE TABLE IF NOT EXISTS PAGES (ID INTEGER PRIMARY KEY AUTOINCREMENT, PHOTOLIBRARYID TEXT, SEQUENCENUMBER INTEGER, FRAMEID TEXT, FILTERID TEXT, BOOKID INTEGER, FOREIGN KEY(BOOKID) REFERENCES STORYBOOKS(ID))"
                
                //Emojis Table
                let sql_stmt3 = "CREATE TABLE IF NOT EXISTS EMOJIS (ID INTEGER PRIMARY KEY AUTOINCREMENT, EMOJIID INTEGER, XCOORD INTEGER, YCOORD INTEGER, ZCOORD INTEGER, PAGEID INTEGER, FOREIGN KEY(PAGEID) REFERENCES PAGES(ID))"
                
                
                if !contactDB.executeStatements(sql_stmt1)
                {
                    print("Error: \(contactDB.lastErrorMessage())")
                }
                if !contactDB.executeStatements(sql_stmt2)
                {
                    print("Error: \(contactDB.lastErrorMessage())")
                }
                if !contactDB.executeStatements(sql_stmt3)
                {
                    print("Error: \(contactDB.lastErrorMessage())")
                }
                //print("Database tables created successfully")
                contactDB.close()
            }
            else
            {
                print("Error: \(contactDB.lastErrorMessage())")
            }
        }
        
    }
    
    func removeStory(sId: Int) {
        let contactDB = FMDatabase(path: databasePath as String)
        
        if contactDB.open()
        {
            let deleteSQL = "DELETE FROM STORYBOOKS WHERE ID = \(sId)"
            
            let result = contactDB.executeUpdate(deleteSQL, withArgumentsInArray: nil)
            
            if !result
            {
                print("Error: \(contactDB.lastErrorMessage())")
            }
            else
            {
                //print("Successfully deleted story from database")
            }
        }
        contactDB.close()
        
    }
    
    func removePage(pId: Int) {
        let contactDB = FMDatabase(path: databasePath as String)
        
        if contactDB.open()
        {
            let deleteSQL = "DELETE FROM PAGES WHERE ID = \(pId)"
            
            let result = contactDB.executeUpdate(deleteSQL, withArgumentsInArray: nil)
            
            if !result
            {
                print("Error: \(contactDB.lastErrorMessage())")
            }
            else
            {
                //print("Successfully deleted page from database")
            }
        }
        contactDB.close()
    }
}