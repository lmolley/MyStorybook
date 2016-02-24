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
                newPage.storyId = storyId
                
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
            let insertSQL = "INSERT INTO PAGES (photolibraryid, sequencenumber, bookid) VALUES ('\(page.photoId)', '\(page.number)', '\(page.storyId)')"
            
            let result = contactDB.executeUpdate(insertSQL, withArgumentsInArray: nil)
            
            if !result
            {
                //print("Did not successfully add page to database")
                print("Error: \(contactDB.lastErrorMessage())")
            }
            else
            {
                //print("Successfully added page to database")
            }
        }
        contactDB.close()
        
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
                let sql_stmt1 = "CREATE TABLE IF NOT EXISTS STORYBOOKS (ID INTEGER PRIMARY KEY AUTOINCREMENT, ICON TEXT, TITLE TEXT)"
                let sql_stmt2 = "CREATE TABLE IF NOT EXISTS PAGES (ID INTEGER PRIMARY KEY AUTOINCREMENT, PHOTOLIBRARYID TEXT, SEQUENCENUMBER INTEGER, BOOKID INTEGER, FOREIGN KEY(BOOKID) REFERENCES STORYBOOKS(ID))"
                
                if !contactDB.executeStatements(sql_stmt1)
                {
                    print("Error: \(contactDB.lastErrorMessage())")
                }
                if !contactDB.executeStatements(sql_stmt2)
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