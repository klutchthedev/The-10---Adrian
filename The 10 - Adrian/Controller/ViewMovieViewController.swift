//
//  ViewMovieViewController.swift
//  The 10 - Adrian
//
//  Created by Adrian Navarro on 2/16/19.
//  Copyright © 2019 Adrian Navarro. All rights reserved.
//

import UIKit
import Alamofire
import SafariServices
import YoutubeKit

class ViewMovieViewController: UIViewController, UIScrollViewDelegate {
    
    let backgroundColor = UIColor(red: 0.220, green: 0.220, blue: 0.220, alpha: 1.00)
    
    
    
    // Origin Point of Tapped Movie
    var centerX = CGFloat()
    var centerY = CGFloat()
    let screenWidth = UIScreen.main.bounds.width
    var movie: Movie?
    var similar = [Movie]()
    var actors = [CrewMember]()
    var trailerLink: URL?
    var player: YTSwiftyPlayer!
    var youtubeID = ""
    let imagesBaseUrlString = "https://image.tmdb.org/t/p/"
    var mpaaRating = "N/A"
    var firstLoad = true
    var trending = false
    var scrollViewSubviews = [UIView]()
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
      
    }
    
    func setupView() {
        
        setupCollectionViews()
        self.view.backgroundColor = UIColor(red: 0.220, green: 0.220, blue: 0.220, alpha: 1.00).withAlphaComponent(1)
        backgroundScrollView.delegate = self
        
        
        //MARK: Add Views
        view.addSubview(navigationBar)
        view.addSubview(backgroundScrollView)
        
        scrollViewSubviews = [backdropImageView, ratingLabel, descriptionLabel, actorsCollectionView, playTrailerButton, trailerVideoView, releaseDateLabel, mpaaRatingLabel, runtimeLabel, genreLabel, similarTitlesLabel, similarMoviesCollectionView]
        
        for view in scrollViewSubviews {
            self.backgroundScrollView.addSubview(view)
            view.alpha = 0
            
        }
        
        //Kept PosterImageView out of array in order to loop through array views alphas in viewDidAppear
        backgroundScrollView.addSubview(posterImageView)
        view.bringSubviewToFront(navigationBar)

        
        
        
        //Mark: Setup Autolayout
        backgroundScrollView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
        backdropImageView.anchor(top: backgroundScrollView.topAnchor, leading: backgroundScrollView.leadingAnchor, bottom: nil, trailing: backgroundScrollView.trailingAnchor, size: .init(width: screenWidth, height: screenWidth * 0.8))
        descriptionLabel.anchor(top: nil, leading: backgroundScrollView.leadingAnchor, bottom: nil, trailing: posterImageView.leadingAnchor, padding: .init(top: 0, left: 7, bottom: 0, right: 13))
        descriptionLabel.topAnchor.constraint(equalTo: posterImageView.centerYAnchor, constant: 0).isActive = true
        
        self.view.layoutIfNeeded()
        backdropImageView.setGradient(colorOne: backgroundColor.withAlphaComponent(1.0), colorTwo: backgroundColor.withAlphaComponent(0.8), colorThree: backgroundColor.withAlphaComponent(0.3), colorFour: backgroundColor.withAlphaComponent(0.2))
        
        
        
        
        navigationBar.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor)
        navigationBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        self.view.layoutIfNeeded()
        
        ratingLabel.centerXAnchor.constraint(equalTo: posterImageView.centerXAnchor).isActive = true
        ratingLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 0).isActive = true
        
        
        actorsCollectionView.anchor(top: playTrailerButton.bottomAnchor, leading: backgroundScrollView.leadingAnchor, bottom: nil, trailing: backgroundScrollView.trailingAnchor, padding: .init(top: 32, left: 0, bottom: 0, right: 0), size: CGSize(width: 0, height: 100))
        
        
        
        
        
        
        self.releaseDateLabel.anchor(top: descriptionLabel.bottomAnchor, leading: backgroundScrollView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 17, left: 9, bottom: 0, right: 0))
        
        playTrailerButton.anchor(top: releaseDateLabel.bottomAnchor, leading: backgroundScrollView.leadingAnchor, bottom: nil, trailing: backgroundScrollView.trailingAnchor, padding:  .init(top: 2, left: 9, bottom: 0, right: 9), size: .init(width: 0, height: 35))
        mpaaRatingLabel.anchor(top: releaseDateLabel.topAnchor, leading: releaseDateLabel.trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 10, bottom: 0, right: 0))
        
        runtimeLabel.anchor(top: mpaaRatingLabel.topAnchor, leading: mpaaRatingLabel.trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 10, bottom: 0, right: 0))
        
        genreLabel.anchor(top: runtimeLabel.topAnchor, leading: runtimeLabel.trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 10, bottom: 0, right: 0))
        
        
        similarTitlesLabel.anchor(top: actorsCollectionView.bottomAnchor, leading: backgroundScrollView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 8, left: 8, bottom: 0, right: 0))
        
        similarMoviesCollectionView.anchor(top: similarTitlesLabel.bottomAnchor, leading: backgroundScrollView.leadingAnchor, bottom: nil, trailing: backgroundScrollView.trailingAnchor, padding: .init(top: 6, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 420))

        
        self.view.layoutIfNeeded()
        
        
        //Set up Navigation Bar
        let closeMovieInfoButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeViewMovie))
        let homeButton = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(handleHomeButtonTapped))
        
        homeButton.tintColor = .white
        closeMovieInfoButton.tintColor = .white
        
       
        let navigationItem = UINavigationItem(title: "Title")
        navigationItem.rightBarButtonItem = closeMovieInfoButton
        navigationItem.leftBarButtonItem = homeButton
        
        //When transitioning from home firstload is always to to true, when transitioning from another movie, firstload it false
        if self.firstLoad == true {
            navigationItem.leftBarButtonItem = nil
            closeMovieInfoButton.title = "Close"
        } else {
        
            closeMovieInfoButton.title = "Go Back"
        }
        
        
       
        navigationBar.items = [navigationItem]
        
        
        
        //Set Starting Point of Movie Poster Image
        if self.trending == false {
        posterImageView.center.x = centerX
        posterImageView.center.y = centerY
        } else {
        posterImageView.center.x = self.screenWidth - 12
        posterImageView.center.y = self.backdropImageView.frame.maxY + 30
        }
        
        //Add Button Targets
        playTrailerButton.addTarget(self, action: #selector(handlePlayTrailer), for: .touchUpInside)
      
        
        
        
        
        //Checks if Movie Exist Before Populating
        if let movie = self.movie {
            
            populateMovieInfo(movie: movie)
            
            //Grab Trailer For Movie
            self.grabTrailers(movie: movie)
            
            
            
            //Format Release Date for Label Depending on Date
            self.releaseDateLabel.text = self.formatReleaseDateForLabel(movie: movie)
            
            
            
            
            //Grab Actors/Cast For Movie
            grabMovieInfo(movie: movie) { (actors) in
                

            }
            
        }
    }
    
    
    func formatReleaseDateForLabel(movie: Movie) -> (String) {
        let calendar = Calendar(identifier: .gregorian)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = calendar
        
        if let releaseDate = formatter.date(from: movie.releaseDate) {
            let year = calendar.component(.year, from: releaseDate)
            let day = calendar.component(.day, from: releaseDate)
            let month = calendar.component(.month, from: releaseDate)
            
            //Check if release date if before or after today
            if releaseDate >= Date() {
                //If after or day of, set label to full date
                self.releaseDateLabel.textColor = .green
                return "\(month)-\(day)-\(year)"
                
            } else {
                //if before, set label to release year.
                 return String(year)
                
            }
            
        } else {
            return "N/A"
        }
    }
    
    
    
    func grabTrailers(movie: Movie) {
        
            let videosUrlString = "https://api.themoviedb.org/3/movie/\(movie.id)/videos?api_key=5db508441873a76f31ced3f6eafa0977"
            if let url = URL(string: videosUrlString) {
                Alamofire.request(url).responseJSON { (response) in
                    if let json = response.result.value as? [String: Any] {
                        
                        let videoInfoArray = json["results"] as! [[String:Any]]
                        
                        //Loop through Movie Video Dictionary
                        for video in videoInfoArray {
                            guard let videoID = video["key"] as? String else {
                                return
                            }
                            let type = video["type"] as? String
                            let site = video["site"] as? String
                            
                            //Checks for first Relevant Trailer Video, Sets the VideoID, then Returns Loop
                            if site == "YouTube" && videoID != "" && type == "Trailer" {
                                
                                self.player = YTSwiftyPlayer(
                                    frame: CGRect(x: -500, y: 0, width: self.screenWidth, height: self.screenWidth * 0.80),
                                    playerVars: [.playsInline(true), .videoID(videoID), .loopVideo(false), .showRelatedVideo(false), .showControls(VideoControlAppearance.hidden), .showInfo(false), .showModestbranding(false)])
                                
                                // Enable auto playback when video is loaded
                                self.player.autoplay = true
                                self.player.isHidden = true
                                
                                self.player.clipsToBounds = true
                                // Set delegate for detect callback information from the player.
                                self.player.delegate = self
                                
                                // Load the video.
                                self.player.loadPlayer()
                                
                                self.player.isUserInteractionEnabled = false
                                
                                self.playTrailerButton.isEnabled = true
                                //Set the Movie Youtube Trailer ID to the VideoID
                                self.youtubeID = videoID
                                
                                return
                            }
                        }
                    }
                }
            }
    }
    
    
    
    
    @objc func handleHomeButtonTapped() {
        self.player.stopVideo()
        let homeVC = MoviesHomeViewController()
        homeVC.modalTransitionStyle = .crossDissolve
        self.present(homeVC, animated: true) {
            
        }
    }
    
    
    @objc func handlePlayTrailer() {
            
        
        //Handles First Play
        if player.isHidden == true {
            playTrailerButton.isSelected = true
            self.backgroundScrollView.addSubview(player)
        }
        
        
        //Playing and Pausing Trailer
        
        if player.isHidden == false && playTrailerButton.isSelected == false {
            
            player.playVideo()
            
        } else if player.isHidden == false && playTrailerButton.isSelected == true {

            player.pauseVideo()
        }
    }
    
    
    func grabMovieInfo(movie: Movie, completionHandler: @escaping ([CrewMember]) ->()) {
       let creditsUrlString = "https://api.themoviedb.org/3/movie/\(movie.id)?api_key=5db508441873a76f31ced3f6eafa0977&language=en-US&append_to_response=credits,videos,release_dates,similar,reviews"
        
            if let url = URL(string: creditsUrlString) {
            Alamofire.request(url).responseJSON { (response) in
                    if let json = response.result.value as? [String: Any] {
                    
                        if let runtime = json["runtime"] as? Int {
                            
                            
                            let tuple = self.minutesToHoursMinutes(minutes: runtime)
                            
                            self.runtimeLabel.text = "\(tuple.hours)h \(tuple.leftMinutes)m"
                            
                        }
                    
                //Checking If Reference To Cast Exist in API Response
                        if let credits = json["credits"] as? [String:Any] {
                            if let castArray = credits["cast"] as? [[String:Any]] {
                                self.actors = castArray.map { CrewMember(dictionary: $0) }
                                self.actorsCollectionView.reloadData()
                            }
                        }
                    
                    
                 //Dig through the Release Date JSON to Grab US MPAA Rating
                        if let releaseDates = json["release_dates"] as? [String:Any] {
                            if let results = releaseDates["results"] as? [[String:Any]] {
                            self.grabMpaaRating(results: results)
                            }
                        }
                        
                //Grab Genres
                        if let genres = json["genres"] as? [[String: Any]] {
                            var newGenres = [String]()
                            for (index, genre) in genres.enumerated() {
                                if let genreName = genre["name"] as? String {
                                    newGenres.insert(genreName, at: newGenres.endIndex)
                                    if index == genre.count - 1 {
                                        let genreString = newGenres.joined(separator: ", ")
                                        self.genreLabel.text = genreString
                                    }
                                }
                            }
                        }
                        
                //Grab Similar Movies
                        if let similar = json["similar"] as? [String: Any] {
                            let results = similar["results"] as! [[String:Any]]
                            self.similar = results.map { Movie(dictionary: $0) }
                            self.similarMoviesCollectionView.reloadData()
                            
                        }
                    
                }
            }
        }
    }
    
    
    func minutesToHoursMinutes (minutes : Int) -> (hours : Int , leftMinutes : Int) {
        return (minutes / 60, (minutes % 60))
    }
    
    
    
    func grabMpaaRating(results: [[String:Any]]) {
        var usRegion = results.filter { $0["iso_3166_1"] as! String == "US" }
        if usRegion.count > 0 {
            let releaseDates = usRegion[0]
            if let ratings = releaseDates["release_dates"] as? [[String:Any]] {
                if let mpaaRating = ratings[0]["certification"] as? String {
                self.mpaaRating = mpaaRating
                self.mpaaRatingLabel.text = mpaaRating
                }
            }
        }
    }
    
    
    
    override func viewDidLayoutSubviews() {
        //Set ScrollView Heigh After Subviews Layout
        backgroundScrollView.contentSize = CGSize(width: self.view.frame.width, height: (self.view.frame.height * 0.6) + 600)
    }
    
    override var prefersStatusBarHidden: Bool {
        //Hide Status Bar
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
       //Call Animation for Poster To Move from Touch to New Postition
        movePosterToPosition()
        
    }
    
    func populateMovieInfo(movie: Movie) {
        
        
        //Convert Double to Percentage String
        let percentage = String(Int(movie.rating * 10))
        ratingLabel.text = percentage + "%"
        
        descriptionLabel.text = movie.description
        
        
        //Check Rating to Determine Label Color
        switch Int(movie.rating) {
        case 0..<6: ratingLabel.textColor = UIColor(red: 0.753, green: 0.000, blue: 0.000, alpha: 1.00)
        case 6..<7: ratingLabel.textColor = UIColor(red: 1.000, green: 0.910, blue: 0.200, alpha: 1.00)
        case 7..<9: ratingLabel.textColor = UIColor(red: 0.855, green: 0.439, blue: 0.016, alpha: 1.00)
        case 9...10: ratingLabel.textColor = UIColor(red: 0.110, green: 0.643, blue: 0.004, alpha: 1.00)
        default: break
        }
        
        
        
        
        //Set Back Drop Image
        guard let url = URL(string: imagesBaseUrlString + "w500" +  movie.backdrop) else {
            self.backdropImageView.image = self.posterImageView.image
            return
        }
        
        self.backdropImageView.sd_setImage(with: url, completed: nil)
    }
    
    
    
    func movePosterToPosition() {
        UIView.animate(withDuration: 0.20, animations: {
            self.backgroundScrollView.backgroundColor = UIColor(red: 0.220, green: 0.220, blue: 0.220, alpha: 1.00).withAlphaComponent(0)
            self.posterImageView.center.x = self.screenWidth - 12
            self.posterImageView.center.y = self.backdropImageView.frame.maxY + 30
            self.posterImageView.frame.size.width = 68
            self.posterImageView.frame.size.height = 102
            for view in self.scrollViewSubviews {
                view.alpha = 1
            }
            if self.trending == false {
                self.view.layoutIfNeeded()
            }
        }) { (done) in
            if self.trending == true {
               self.posterImageView.isHidden = false
            }
        }
        
        UIView.animate(withDuration: 0.20) {
            
        }
        
    }
    
    @objc func closeViewMovie() {
        if self.trending == false {
        posterImageView.isHidden = false
        UIView.animate(withDuration: 0.20, animations: {
            self.backgroundScrollView.backgroundColor = UIColor(red: 0.220, green: 0.220, blue: 0.220, alpha: 1.00).withAlphaComponent(1)
            self.posterImageView.frame.size.width = 133.333
            self.posterImageView.frame.size.height = 200
            self.posterImageView.center.x = self.centerX
            self.posterImageView.center.y = self.centerY
            for view in self.scrollViewSubviews {
                view.alpha = 0
            }
            self.view.layoutIfNeeded()
        }) { (done) in
            self.dismiss(animated: true, completion: nil)
        }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    //MARK: Create Views
    
    
    
    //MARK: UIImageViews
    let posterImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 133.333, height: 200)
        imageView.clipsToBounds = true
        imageView.backgroundColor = .green
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let backdropImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    
    //MARK: UIButtons

    
    let playTrailerButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 0.741, green: 0.067, blue: 0.031, alpha: 1.00)
        button.setTitle("Play Trailer", for: .normal)
        button.isEnabled = false
        button.adjustsImageWhenDisabled = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.tintColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white, for: .selected)
        return button
    }()
    
    
    //MARK: ScrollView
    var backgroundScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor(red: 0.220, green: 0.220, blue: 0.220, alpha: 1.00).withAlphaComponent(1)
        scrollView.scrollsToTop = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.alpha = 1
        return scrollView
    }()
    
     //MARK: CollectionViews
    let actorsCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout.init())
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    let similarMoviesCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout.init())
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    let actorCollectionViewFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: 80, height: 100)
        return layout
    }()
    let similarMoviesCollectionFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: 133.33, height: 200)
        return layout
    }()
    
    
    //MARK: UIViews
    var trailerVideoView: UIView = {
        let view = UIView()
        let screenWidth = UIScreen.main.bounds.width
        view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth * 0.75)
        return view
    }()
    
    
    //MARK: UILabels
    var ratingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    var releaseDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = UIColor(red: 0.557, green: 0.557, blue: 0.557, alpha: 1.00)
        return label
    }()
    
    var mpaaRatingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.layer.borderWidth = 0.7
        label.layer.cornerRadius = 1.5
        label.layer.borderColor = UIColor(red: 0.557, green: 0.557, blue: 0.557, alpha: 1.00).cgColor
        label.textColor = UIColor(red: 0.557, green: 0.557, blue: 0.557, alpha: 1.00)
        return label
    }()
    
    var runtimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = UIColor(red: 0.557, green: 0.557, blue: 0.557, alpha: 1.00)
        return label
    }()
    
    var genreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = UIColor(red: 0.557, green: 0.557, blue: 0.557, alpha: 1.00)
        return label
    }()
    
    var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = .white
        label.numberOfLines = 6
        return label
    }()
    
    let similarTitlesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        label.text = "Similar Titles"
        label.textColor = UIColor.white
        return label
    }()
    
    

    //MARK: Navigation Bar
    let navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar()
        navigationBar.barTintColor = UIColor.clear
        navigationBar.backgroundColor = .clear
        navigationBar.isTranslucent = true
        navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationBar.shadowImage = UIImage()
        return navigationBar
    }()
    
   

}

  // MARK: - UICollectionViewDataSource && UICollectionViewDataSource

extension ViewMovieViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == actorsCollectionView {
        return actors.count
        } else {
        return similar.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == actorsCollectionView {
        guard let actorCell = collectionView.dequeueReusableCell(withReuseIdentifier: "actorCell", for: indexPath) as? ActorCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        actorCell.isUserInteractionEnabled = false
        let actor = actors[indexPath.row]
        populateActor(actor: actor, actorCell: actorCell)
        
        
        return actorCell
        } else {
            guard let movieCell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as? MovieCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            let movie = similar[indexPath.row]
            
            let photoURL = URL(string: imagesBaseUrlString + "w200" + movie.posterPath)
            movieCell.posterImageView.sd_setImage(with: photoURL!, completed: nil)
            
            
            return movieCell
            
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let movieCell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as? MovieCollectionViewCell else {
            return
        }
        
        if collectionView == similarMoviesCollectionView {
        let movie = similar[indexPath.row]
            
        //Grab The Center of Tapped Cell for Animation Start Point
        let centerX = movieCell.center.x - collectionView.contentOffset.x
        let centerY = collectionView.center.y - self.backgroundScrollView.contentOffset.y
        let cell = similarMoviesCollectionView.cellForItem(at: indexPath) as! MovieCollectionViewCell
        viewMovie(image: cell.posterImageView.image ?? UIImage(named: "No Photo")!, movie: movie, centerX: centerX, centerY: centerY)
        }
    }
    
    func setupCollectionViews() {
        actorsCollectionView.collectionViewLayout = actorCollectionViewFlowLayout
        actorsCollectionView.register(ActorCollectionViewCell.self, forCellWithReuseIdentifier: "actorCell")
        actorsCollectionView.delegate = self
        actorsCollectionView.dataSource = self
        
        
        similarMoviesCollectionView.collectionViewLayout = similarMoviesCollectionFlowLayout
        similarMoviesCollectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: "movieCell")
        similarMoviesCollectionView.delegate = self
        similarMoviesCollectionView.dataSource = self
    }
    
    
    
    func populateActor(actor: CrewMember, actorCell: ActorCollectionViewCell) {
        if let url = URL(string: imagesBaseUrlString + "w200" + actor.headShotPath) {
            actorCell.actorImageView.sd_setImage(with: url) { (image, error, cache, url) in
                if error != nil || image == nil {
                    actorCell.actorImageView.image = UIImage(named: "No Image")
                }
                actorCell.actorNameLabel.text = actor.name
                
            }
        }
    }
    
    
    
    func viewMovie(image: UIImage, movie: Movie, centerX: CGFloat, centerY: CGFloat) {
        let viewMovieVC = ViewMovieViewController()
        viewMovieVC.modalPresentationStyle = .overCurrentContext
        viewMovieVC.modalTransitionStyle = .crossDissolve
        viewMovieVC.posterImageView.image = image
        viewMovieVC.centerX = centerX
        viewMovieVC.firstLoad = false
        viewMovieVC.centerY = centerY
        viewMovieVC.movie = movie
        self.present(viewMovieVC, animated: false) {
            
        }
        
        
    }
    
    
    
    
}



extension ViewMovieViewController: YTSwiftyPlayerDelegate {
    
    func player(_ player: YTSwiftyPlayer, didChangeState state: YTSwiftyPlayerState) {
        
        switch player.playerState {
            
        case .buffering:
            
            if self.playTrailerButton.isSelected == true {
            UIView.animate(withDuration: 0.2) {
                self.playTrailerButton.isSelected = true
                self.playTrailerButton.setTitle("Loading...", for: .selected)
                self.playTrailerButton.backgroundColor = .lightGray
                self.view.layoutIfNeeded()
            }
            
            
            UIView.animate(withDuration: 0.3) {
                self.player.frame.origin.x = 0
                self.posterImageView.frame.origin.y = self.backdropImageView.frame.maxY + 12
                self.playTrailerButton.backgroundColor = .lightGray
                self.view.layoutIfNeeded()
            }
            }
            
           

        
        case .playing:
        
            self.player.isHidden = false
            
        UIView.animate(withDuration: 0.3) {
            self.playTrailerButton.isSelected = true
            self.player.frame.origin.x = 0
            self.posterImageView.frame.origin.y = self.backdropImageView.frame.maxY + 12
            self.playTrailerButton.backgroundColor = .lightGray
            self.playTrailerButton.setTitle("Pause Trailer", for: .selected)
            self.backgroundScrollView.bringSubviewToFront(self.player)
            self.view.layoutIfNeeded()
            }
        
            
        case .paused:
            self.playTrailerButton.isSelected = false

            
            UIView.animate(withDuration: 0.2) {
                self.playTrailerButton.setTitle("Play Trailer", for: .normal)
                self.playTrailerButton.backgroundColor = UIColor(red: 0.741, green: 0.067, blue: 0.031, alpha: 1.00)
                self.backgroundScrollView.bringSubviewToFront(self.backdropImageView)
                self.player.frame.origin.x = -500
                self.posterImageView.center.y = self.backdropImageView.frame.maxY + 30
                self.backgroundScrollView.bringSubviewToFront(self.posterImageView)
                self.backgroundScrollView.bringSubviewToFront(self.descriptionLabel)
                
                self.view.layoutIfNeeded()
                self.descriptionLabel.topAnchor.constraint(equalTo: self.posterImageView.topAnchor, constant: 51).isActive = true

                
            }
            
            
            
        default: break
        
        }
    }
    

    
    
}


