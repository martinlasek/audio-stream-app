import UIKit

// Cache to store fetched images
let imageCache = NSCache<AnyObject, AnyObject>()

class AsyncImageView: UIImageView {
  var task: URLSessionDataTask!
  let spinner = UIActivityIndicatorView(style: .medium)

  func loadImage(from url: URL) {
    // Set image to nil
    // so you don't see the former image when a new image
    // is just about to be set from the cache or api
    self.image = nil

    self.startSpinner()

    // Cancel the former task so we don't have
    // a finishing task from before setting an image
    // that we don't want anymore
    if let task = self.task {
      task.cancel()
    }

    // If there's an image in the cache at the key (url is the key here)
    // set the image from the cache and early return
    if let imageFromCache = imageCache.object(forKey: url.absoluteString as AnyObject) as? UIImage {
      setImage(image: imageFromCache)
      self.endSpinner()
      return
    }

    // Download the image
    // store it in cache with the url as a key and set the image of this image view
    task = URLSession.shared.dataTask(with: url) { (data, response, error) in
      guard
        let data = data,
        let newImage = UIImage(data: data)
      else {
        print("❌ \(Self.self): Couldn't load image from url: \(url.description)")
        return
      }

      imageCache.setObject(newImage, forKey: url.absoluteString as AnyObject)
      DispatchQueue.main.async {
        self.setImage(image: newImage)
        self.endSpinner()
      }
    }

    task.resume()
  }

  func setImage(image: UIImage) {
    self.image = image
  }

  func startSpinner() {
    self.addSubview(self.spinner)
    self.spinner.translatesAutoresizingMaskIntoConstraints = false
    self.spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    self.spinner.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    self.spinner.startAnimating()
  }

  func endSpinner() {
    self.spinner.removeFromSuperview()
  }
}
