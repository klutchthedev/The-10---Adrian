//
//  ViewController.swift
//  The 10 - Adrian
//
//  Created by Adrian Navarro on 2/15/19.
//  Copyright © 2019 Adrian Navarro. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import SVProgressHUD

class MoviesHomeViewController: UIViewController {
    
    let backgroundColor = UIColor(red: 0.220, green: 0.220, blue: 0.220, alpha: 1.00)
    var latestMovie: Movie?
    var nowPlayingMovies = [Movie]()
    let nowPlayingUrlString = "https://api.themoviedb.org/3/movie/now_playing?api_key=5db508441873a76f31ced3f6eafa0977&language=en-US&page=1&region=US"
    var upcomingMovies = [Movie]()
    let upcomingUrlString = "https://api.themoviedb.org/3/movie/upcoming?api_key=5db508441873a76f31ced3f6eafa0977&language=en-US&page=1&region=US"
    let screenWidth = UIScreen.main.bounds.width
    let imagesBaseUrlString = "https://image.tmdb.org/t/p/w500"
    var trendingMovies = [Movie]()
    var presentedTrendingMovie: Movie?

    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup View
        setupView()
        }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    
    
    override func viewDidLayoutSubviews() {
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: (self.view.frame.height * 0.6) + 520)
    }
    
    
    func setupView() {
        
        setupCollectionViews()
        
        //Call Methods to fetch movie data

        grabLatestMovie()
        grabUpcomingMovies()
        grabNowPlayingMovies()
        
        //MARK: Add Views
        
        let scrollViewSubviews = [largeTrendingMoviePoster, nowPlayingTitleLabel, nowPlayingCollectionView, upcomingTitleLabel, upcomingCollectionView, trendingMovieInfoButton, trendingMovieTitleLabel, trendingRatingLabel, trendingMovieNameLabel]
        self.view.addSubview(scrollView)
        
        for view in scrollViewSubviews {
            scrollView.addSubview(view)
        }
        scrollView.delegate = self
        
        
        
        
        
        
        //MARK: Setup AutoLayout
        
        scrollView.anchor(top: self.view.topAnchor, leading: self.view.leadingAnchor, bottom: self.view.bottomAnchor, trailing: self.view.trailingAnchor)
        scrollView.delegate = self
        largeTrendingMoviePoster.anchor(top: scrollView.topAnchor, leading: scrollView.leadingAnchor, bottom: nil, trailing: scrollView.trailingAnchor)
        largeTrendingMoviePoster.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        largeTrendingMoviePoster.heightAnchor.constraint(equalToConstant: self.view.frame.height * 0.6).isActive = true
        nowPlayingTitleLabel.anchor(top: largeTrendingMoviePoster.bottomAnchor, leading: largeTrendingMoviePoster.leadingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 15, left: 8, bottom: 0, right: 0), size: .init(width: 0, height: 20))
        nowPlayingCollectionView.topAnchor.constraint(equalTo: nowPlayingTitleLabel.bottomAnchor, constant: 6).isActive = true
        nowPlayingCollectionView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        nowPlayingCollectionView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        upcomingTitleLabel.anchor(top: nowPlayingCollectionView.bottomAnchor, leading: nowPlayingCollectionView.leadingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 30, left: 8, bottom: 0, right: 0), size: .init(width: 0, height: 20))
        upcomingCollectionView.topAnchor.constraint(equalTo: upcomingTitleLabel.bottomAnchor, constant: 6).isActive = true
        upcomingCollectionView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        upcomingCollectionView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        self.view.layoutIfNeeded()
        trendingMovieInfoButton.addTarget(self, action: #selector(handleTrendingMovieInfoTapped), for: .touchUpInside)
        trendingMovieTitleLabel.anchor(top: scrollView.topAnchor, leading: scrollView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 50, left: 8, bottom: 0, right: 0))
        largeTrendingMoviePoster.alpha = 0.8
        trendingMovieNameLabel.anchor(top: trendingMovieTitleLabel.bottomAnchor, leading: scrollView.leadingAnchor, bottom: nil, trailing: scrollView.trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 100))
         trendingRatingLabel.anchor(top: trendingMovieNameLabel.bottomAnchor, leading: trendingMovieNameLabel.leadingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 7, left: 0, bottom: 0, right: 0))
         trendingMovieInfoButton.anchor(top: nil, leading: trendingRatingLabel.trailingAnchor, bottom: trendingRatingLabel.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 3, bottom: 0, right: screenWidth/5), size: CGSize(width: 25, height: 25))
        self.view.layoutIfNeeded()
        largeTrendingMoviePoster.setGradient(colorOne: backgroundColor.withAlphaComponent(1.0), colorTwo: backgroundColor.withAlphaComponent(0.6), colorThree: backgroundColor.withAlphaComponent(0.3), colorFour: backgroundColor.withAlphaComponent(0.2))
        
        
        
        
        
        
        
        
        
        
        
    }
    
    
    
    
    @objc func handleTrendingMovieInfoTapped() {
       
        if let movie = self.presentedTrendingMovie {
            viewTrending(image: self.largeTrendingMoviePoster.image ?? UIImage(named: "No Photo")!, movie: movie, centerX: largeTrendingMoviePoster.center.x, centerY: largeTrendingMoviePoster.center.y)
            
        }
    }
    
    
    func grabLatestMovie() {
        guard let url = URL(string: "https://api.themoviedb.org/3/trending/movie/week?api_key=5db508441873a76f31ced3f6eafa0977&language=en-US&page=1&region=US") else {
            return
        }
        Alamofire.request(url).responseJSON { (response) in
            if let error = response.error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                
                SVProgressHUD.dismiss(withDelay: 1.8)
            }
            if let json = response.result.value as? [String: Any] {
                
                let results = json["results"] as! [[String:Any]]
                let movies = results.map { Movie(dictionary: $0) }
                self.trendingMovies = movies
                if movies.count > 1 {
                let movie = movies[Int.random(in: 0...movies.count)]
                    
                    self.setupLatestMovie(movie: movie)
                }
                
                
            }
        }
    }
    
    //Grab the Latest Movies Method
    func grabNowPlayingMovies() {
        guard let url = URL(string: nowPlayingUrlString) else {
            return
        }
        Alamofire.request(url).responseJSON { (response) in
            if response.error != nil {
                
                SVProgressHUD.showError(withStatus: response.error?.localizedDescription)
                
                SVProgressHUD.dismiss(withDelay: 1.8)
            }
            if let json = response.result.value as? [String: Any] {
                let results = json["results"] as! [[String:Any]]
                self.nowPlayingMovies = results.map { Movie(dictionary: $0) }
                DispatchQueue.main.async {
                    self.nowPlayingCollectionView.reloadData()
                }
            }
        }
    }
    
    func setupLatestMovie(movie: Movie) {
        self.presentedTrendingMovie = movie
        
        guard let imageURL = URL(string: imagesBaseUrlString + movie.posterPath) else {
            return
        }
        
        largeTrendingMoviePoster.sd_setImage(with: imageURL, completed: nil)
        let percentage = String(Int(movie.rating * 10))
        trendingRatingLabel.text = percentage + "%"
        
        
        switch Int(movie.rating) {
        case 0..<6: trendingRatingLabel.textColor = UIColor(red: 0.753, green: 0.000, blue: 0.000, alpha: 1.00)
        case 6..<7: trendingRatingLabel.textColor = UIColor(red: 1.000, green: 0.910, blue: 0.200, alpha: 1.00)
        case 7..<9: trendingRatingLabel.textColor = UIColor(red: 0.855, green: 0.439, blue: 0.016, alpha: 1.00)
        case 9...10: trendingRatingLabel.textColor = UIColor(red: 0.110, green: 0.643, blue: 0.004, alpha: 1.00)
        default: break
        }
        
        trendingMovieNameLabel.text = movie.title
        
        
    }

    //Grab the Upcoming Movies Method
    func grabUpcomingMovies() {
        guard let url = URL(string: upcomingUrlString) else {
            return
        }
        Alamofire.request(url).responseJSON { (response) in
            if response.error != nil {
                SVProgressHUD.showError(withStatus: response.error?.localizedDescription)
                
                SVProgressHUD.dismiss(withDelay: 1.8)
            }
            
            if let json = response.value as? [String: Any] {
                let results = json["results"] as! [[String:Any]]
                
                self.upcomingMovies = results.map { Movie(dictionary: $0) }
                
                DispatchQueue.main.async {
                    self.upcomingCollectionView.reloadData()

                }
                
            }
        }
    }
    
    
    func viewTrending(image: UIImage, movie: Movie, centerX: CGFloat, centerY: CGFloat) {
        let viewMovieVC = ViewMovieViewController()
        viewMovieVC.modalPresentationStyle = .overCurrentContext
        viewMovieVC.modalTransitionStyle = .crossDissolve
        viewMovieVC.posterImageView.image = image
        viewMovieVC.centerX = centerX
        viewMovieVC.centerY = centerY
        viewMovieVC.movie = movie
        viewMovieVC.trending = true
        viewMovieVC.posterImageView.isHidden = true
        self.present(viewMovieVC, animated: false)
        
        
    }
    
    
    
    
    
    //MARK: ScrollView
     var scrollView: UIScrollView = {
        let instance = UIScrollView()
        instance.backgroundColor = UIColor(red: 0.220, green: 0.220, blue: 0.220, alpha: 1.00)
        instance.scrollsToTop = false
        instance.showsVerticalScrollIndicator = false
        instance.contentInsetAdjustmentBehavior = .never
        return instance
    }()
    
    
    //MARK: UIImageViews
    let largeTrendingMoviePoster: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = UIColor(red: 0.220, green: 0.220, blue: 0.220, alpha: 1.00)
        return imageView
    }()

    
    
    //MARK: UILabels
    var trendingRatingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.shadowOffset = CGSize(width: 0, height: 2)
        label.layer.shadowRadius = 20
        label.layer.shadowOpacity = 1
        return label
    }()
    
    let nowPlayingTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        label.text = "Now Playing"
        label.textColor = UIColor.white
        return label
    }()
    
    
    let upcomingTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        label.text = "Upcoming"
        label.textColor = UIColor.white
        return label
    }()
    
    let trendingMovieTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.text = "Trending Movie:"
        label.textColor = UIColor.white
        label.shadowOffset = CGSize(width: 0, height: 0)
        label.layer.shadowOpacity = 1
        return label
    }()
    
    let trendingMovieNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        label.text = ""
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.textAlignment = .left
        label.shadowOffset = CGSize(width: 0, height: 0)
        label.layer.shadowOpacity = 1
        return label
    }()
    
    
    
    
    
    //MARK: CollectionViews
    let nowPlayingCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout.init())
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    let upcomingCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout.init())
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    
    let movieCollectionFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: 133.33, height: 200)
        return layout
    }()
    
    let topRated: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: 133.33, height: 200)
        return layout
    }()
    
    
    //MARK: UIButtons
    let trendingMovieInfoButton: UIButton = {
        let button = UIButton(type: .infoLight)
        button.tintColor = .white
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        button.layer.shadowOpacity = 1
        return button
    }()
    
    
}



// MARK: - UICollectionViewDataSource && UICollectionViewDataSource
extension MoviesHomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == upcomingCollectionView {
            return upcomingMovies.count
        } else {
        return nowPlayingMovies.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let movieCell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as? MovieCollectionViewCell else {
            return UICollectionViewCell()
        }
        if collectionView == upcomingCollectionView {
            
            let movie = upcomingMovies[indexPath.row]
            movieCell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
            let photoURL = URL(string: imagesBaseUrlString + movie.posterPath)
            movieCell.posterImageView.sd_setImage(with: photoURL!, completed: nil)
        } else {
            
            let movie = nowPlayingMovies[indexPath.row]
            movieCell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
            let photoURL = URL(string: imagesBaseUrlString + movie.posterPath)
            movieCell.posterImageView.sd_setImage(with: photoURL!, completed: nil)
            
        }
        return movieCell
    }
    

    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let movieCell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as? MovieCollectionViewCell else {
            return
        }
        
        if collectionView == nowPlayingCollectionView {
            let movie = nowPlayingMovies[indexPath.row]
           
            
            let centerX = movieCell.center.x - collectionView.contentOffset.x
            let centerY = collectionView.center.y - self.scrollView.contentOffset.y
            let cell = nowPlayingCollectionView.cellForItem(at: indexPath) as! MovieCollectionViewCell
            let image = cell.posterImageView.image
            
            viewMovie(image: image ?? UIImage(named: "No Photo")!, movie: movie, centerX: centerX, centerY: centerY)
            
        } else {
            let movie = upcomingMovies[indexPath.row]
          
            
            
            let centerX = movieCell.center.x - collectionView.contentOffset.x
            let centerY = collectionView.center.y - self.scrollView.contentOffset.y
            let cell = upcomingCollectionView.cellForItem(at: indexPath) as! MovieCollectionViewCell
            let image = cell.posterImageView.image
            
            viewMovie(image: image ?? UIImage(named: "No Photo")!, movie: movie, centerX: centerX, centerY: centerY)
        }
        
        
        
        
        
    
    }
    
    func setupCollectionViews() {
        nowPlayingCollectionView.collectionViewLayout = movieCollectionFlowLayout
        nowPlayingCollectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: "movieCell")
        nowPlayingCollectionView.delegate = self
        nowPlayingCollectionView.dataSource = self
        
        upcomingCollectionView.collectionViewLayout = movieCollectionFlowLayout
        upcomingCollectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: "movieCell")
        upcomingCollectionView.delegate = self
        upcomingCollectionView.dataSource = self
        
    }
    
    func viewMovie(image: UIImage, movie: Movie, centerX: CGFloat, centerY: CGFloat) {
        let viewMovieVC = ViewMovieViewController()
        viewMovieVC.modalPresentationStyle = .overCurrentContext
        viewMovieVC.modalTransitionStyle = .crossDissolve
        viewMovieVC.posterImageView.image = image
        viewMovieVC.centerX = centerX
        viewMovieVC.centerY = centerY
        viewMovieVC.movie = movie
        self.present(viewMovieVC, animated: false) {
            
        }
        
        
    }
    
    
    
    
    
    
    
}
    
    
    

