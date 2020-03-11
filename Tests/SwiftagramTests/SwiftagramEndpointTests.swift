@testable import Swiftagram
import XCTest

final class SwiftagramEndpointTests: XCTestCase {
    /// Test `Endpoint.Method` .
    func testEndpointMethod() {
        XCTAssert(Endpoint.Method.get.resolve(using: Data()) == "GET")
        XCTAssert(Endpoint.Method.post.resolve(using: nil) == "POST")
        XCTAssert(Endpoint.Method.default.resolve(using: nil) == "GET")
        XCTAssert(Endpoint.Method.default.resolve(using: Data()) == "POST")
    }

    /// Test `Endpoint.Archive`.
    func testEndpointArchive() {
        XCTAssert(Endpoint.Archive
            .stories
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/archive/reel/day_shells/")
    }

    /// Test `Endpoint.Direct`.
    func testEndpointDirect() {
        XCTAssert(Endpoint.Direct
            .threads
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/direct_v2/reel/inbox/")
        XCTAssert(Endpoint.Direct
            .thread(matching: "id")
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/direct_v2/threads/id/")
    }

    /// Test `Endpoint.Feed`.
    func testEndpointFeed() {
        XCTAssert(Endpoint.Feed
            .followedStories
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/feed/reels_tray/")
        XCTAssert(Endpoint.Feed
            .likes
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/feed/liked/")
        XCTAssert(Endpoint.Feed
            .timeline
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/feed/timeline/")
        XCTAssert(Endpoint.Feed
            .posts(by: "id")
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/feed/user/id/")
        XCTAssert(Endpoint.Feed
            .stories(by: "id")
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/feed/user/id/reel_media/")
        XCTAssert(Endpoint.Feed
            .posts(including: "id")
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/usertags/id/feed/")
        XCTAssert(Endpoint.Feed
            .tagged(with: "tag")
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/feed/tag/tag/")
    }

    /// Test `Endpoint.Friendship`.
    func testEndpointFriendship() {
        XCTAssert(Endpoint.Friendship
            .followed(by: "id")
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/friendships/id/following/")
        XCTAssert(Endpoint.Friendship
            .following("id")
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/friendships/id/followers/")
        XCTAssert(Endpoint.Friendship
            .friendship(with: "id")
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/friendships/show/id/")
    }

    /// Test `Endpoint.User`.
    func testEndpointUser() {
        XCTAssert(Endpoint.User
            .summary(for: "id")
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/users/id/info/")
        XCTAssert(Endpoint.User
            .all(matching: "query")
            .request()?
            .url?
            .absoluteString == "https://i.instagram.com/api/v1/users/search/?q=query")
    }
    
    /// Test pagination.
    func testPaginationString() {
        // The current offset.
        let expectation = XCTestExpectation()
        var offset = -1
        let languages = ["de", "it", "fr"]
        // Paginate.
        Endpoint.generic
            .cycleTask(String.self,
                       key: "l",
                       initial: "en",
                       next: { _ in offset += 1; return offset < languages.count ? languages[offset] : nil }) {
                        switch $0 {
                        case .success: break
                        case .failure(let error): XCTFail(error.localizedDescription)
                        }
                        // Finish on the last one.
                        if offset == 2 { expectation.fulfill() }
            }
            .resume()
        wait(for: [expectation], timeout: 30)
    }
    
    /// Test pagination.
    func testPaginationResponse() {
        // The current offset.
        let expectation = XCTestExpectation()
        var offset = -1
        let languages = ["de", "it", "fr"]
        // Paginate.
        Endpoint.generic
            .cycleTask(key: "l",
                       initial: "en",
                       next: { _ in offset += 1; return offset < languages.count ? languages[offset] : nil }) {
                        switch $0 {
                        case .success: break
                        case .failure(let error): XCTFail(error.localizedDescription)
                        }
                        // Finish on the last one.
                        if offset == 2 { expectation.fulfill() }
            }
            .resume()
        wait(for: [expectation], timeout: 30)
    }

    static var allTests = [
        ("Endpoint.Method", testEndpointMethod),
        ("Endpoint.Archive", testEndpointArchive),
        ("Endpoint.Direct", testEndpointDirect),
        ("Endpoint.Feed", testEndpointFeed),
        ("Endpoint.Friendship", testEndpointFriendship),
        ("Endpoint.User", testEndpointUser),
        ("Endpoint.Pagination.String", testPaginationString),
        ("Endpoint.Pagination.Response", testPaginationResponse),
    ]
}
