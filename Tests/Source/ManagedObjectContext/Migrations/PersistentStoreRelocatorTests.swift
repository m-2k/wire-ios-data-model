//
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//

import XCTest
@testable import WireDataModel

class PersistentStoreRelocatorTests: DatabaseBaseTest {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testThatItFindsPreviousStoreInCachesDirectory() {
        // given
        createDatabase(in: .cachesDirectory, accountIdentifier: nil)
        
        // new store is located in documents directory
        let sut = MainPersistentStoreRelocator(sharedContainerURL: self.sharedContainerDirectoryURL,
                                               newStoreURL: FileManager.currentStoreURLForAccount(
                                                with: UUID(), in: self.sharedContainerDirectoryURL))
        
        // then
        XCTAssertEqual(sut.previousStoreLocation, FileManager.storeURL(in: .cachesDirectory)!)
    }
    
    func testThatItFindsPreviousStoreInApplicationSupportDirectory() {
        // given
        createDatabase(in: .applicationSupportDirectory, accountIdentifier: nil)
        
        // new store is located in documents directory
        let sut = MainPersistentStoreRelocator(sharedContainerURL: self.sharedContainerDirectoryURL,
                                               newStoreURL: FileManager.currentStoreURLForAccount(
                                                with: UUID(), in: self.sharedContainerDirectoryURL))
        
        // then
        XCTAssertEqual(sut.previousStoreLocation, FileManager.storeURL(in: .applicationSupportDirectory)!)
        
    }
    
    func testThatIsNecessaryToRelocateStoreIfItsLocatedInAPreviousLocation_and_newStoreAlreadyExists() {
        // given
        let cachesStoreURL = FileManager.storeURL(in: .cachesDirectory)!
        
        createDatabase(in: .documentDirectory, accountIdentifier: nil)
        createDirectoryForStore(at: cachesStoreURL)
        createExternalSupportFileForDatabase(at: cachesStoreURL)
        
        // new store is located in documents directory
        let sut = MainPersistentStoreRelocator(sharedContainerURL: self.sharedContainerDirectoryURL,
                                               newStoreURL: FileManager.currentStoreURLForAccount(
                                                with: UUID(), in: self.sharedContainerDirectoryURL))
        
        // then
        XCTAssertNotNil(sut.previousStoreLocation)
    }
    
    func testThatIsNotNecessaryToRelocateStoreIfNotPreviousStoreExists() {
        // given new store is located in documents directory
        let sut = MainPersistentStoreRelocator(sharedContainerURL: self.sharedContainerDirectoryURL,
                                               newStoreURL: FileManager.currentStoreURLForAccount(
                                                with: UUID(), in: self.sharedContainerDirectoryURL))
        
        // then
        XCTAssertNil(sut.previousStoreLocation)
    }
    
    func testThatIsNotNecessaryToRelocateStoreIfItsLocatedInAPreviousLocation_and_newStoreIsTheSame() {
        // given
        let accountId = UUID()
        createDatabase(in: .documentDirectory, accountIdentifier: accountId)
        
        // new store is also located in caches directory
        let sut = MainPersistentStoreRelocator(sharedContainerURL: self.sharedContainerDirectoryURL,
                                               newStoreURL: FileManager.currentStoreURLForAccount(
                                                with: accountId,
                                                in: self.sharedContainerDirectoryURL))
        
        // then
        XCTAssertNil(sut.previousStoreLocation)
    }
    
}
