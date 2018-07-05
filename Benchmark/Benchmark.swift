// The MIT License (MIT)
//
// Copyright (c) 2015-2018 Alexander Grebenyuk (github.com/kean).

import XCTest
import Nuke
import Alamofire
import AlamofireImage
import Kingfisher
import SDWebImage
import PINRemoteImage
import PINCache
import YYWebImage
import YYCache

// MARK: - Main-Thread Performance

class CacheHitPerformanceTests: XCTestCase {
    let view = UIImageView()
    let image = UIImage(named: "fixture")! // same image so that it gets decoded once
    let urls: [URL] = {
        // 10_000 iterations, but only 100 unique URLs
        return (0..<25_000).map { _ in return URL(string: "http://test.com/\(arc4random_uniform(100)).jpeg")! }
    }()

    func testNuke() {
        for url in self.urls {
            Nuke.ImageCache.shared.storeResponse(ImageResponse(image: image, urlResponse: nil), for: ImageRequest(url: url))
        }

        measure {
            for url in self.urls {
                Nuke.loadImage(with: url, into: self.view)
            }
        }
    }

    func testPINRemoteImage() {
        for url in self.urls {
            let manager = PINRemoteImageManager.shared()
            manager.cache.setObject(image, forKey: manager.cacheKey(for: url, processorKey: nil))
        }

        measure {
            for url in self.urls {
                self.view.pin_setImage(from: url)
            }
        }
    }

    func testAlamofireImage() {
        for url in self.urls {
            UIImageView.af_sharedImageDownloader.imageCache?.add(image, for: URLRequest(url: url), withIdentifier: nil)
        }

        measure {
            for url in self.urls {
                self.view.af_setImage(withURL: url)
            }
        }
    }

    func testKingfisher() {
        for url in self.urls {
            KingfisherManager.shared.cache.store(image, original: nil, forKey: url.absoluteString, processorIdentifier: "", cacheSerializer: DefaultCacheSerializer.default, toDisk: false, completionHandler: nil)
        }

        measure {
            for url in self.urls {
                self.view.kf.setImage(with: url)
            }
        }
    }

    func testSDWebImage() {
        for url in self.urls {
            SDImageCache.shared().store(image, imageData: nil, forKey: url.absoluteString, toDisk: false, completion: nil)
        }

        measure {
            for url in self.urls {
                self.view.sd_setImage(with: url)
            }
        }
    }
    
    func testYYWebImage() {
        for url in self.urls {
            YYWebImageManager.shared().cache?.setImage(image, imageData:nil, forKey: url.absoluteString, with: .memory)
        }
        
        measure {
            for url in self.urls {
                self.view.yy_setImage(with: url, options: [])
            }
        }
    }
}

class CacheMissPerformanceTests: XCTestCase {
    let view = UIImageView()
    let urls: [URL] = {
        return (0..<20_000).map { _ in return URL(string: "http://test.com/\(arc4random()).jpeg")! }
    }()

    func testNuke() {
        measure {
            for url in self.urls {
                Nuke.loadImage(with: url, into: self.view)
            }
        }
    }

    func testPINRemoteImage() {
        measure {
            for url in self.urls {
                self.view.pin_setImage(from: url)
            }
        }
    }

     func testAlamofireImage() {
        measure {
            for url in self.urls {
                self.view.af_setImage(withURL: url)
            }
        }
     }

    func testKingfisher() {
        measure {
            for url in self.urls {
                self.view.kf.setImage(with: url)
            }
        }
    }

    func testSDWebImage() {
        measure {
            for url in self.urls {
                self.view.sd_setImage(with: url)
            }
        }
    }
    
    func testYYWebImage() {
        measure {
            for url in self.urls {
                self.view.yy_setImage(with: url, options: [])
            }
        }
    }
}
