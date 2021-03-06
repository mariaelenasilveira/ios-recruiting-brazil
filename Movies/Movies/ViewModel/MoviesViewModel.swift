//
//  MoviesViewModel.swift
//  Muv Concrete
//
//  Created by Mariaelena Silveira on 15/01/20.
//  Copyright © 2020 Mariaelena Silveira. All rights reserved.
//

import UIKit

class MoviesViewModel {
    
    var delegate: UIViewController?
    
    var arrayMovies: [Movie] = []
    var arrayMoviesSave: [Movie] = []
    var pageRequest = 1
    var limitPage: Int32 = 0
    
    
    public func requestMovies(completionHandler: @escaping (Bool) -> Void){
        let serviceRouteMovies = ServiceRoute.popularMovie(pageRequest)
        let request = Request.instance
        request.dispatch(endPoint: serviceRouteMovies, type: Content.self, completionHandler: { (data, response, error) in
            
            guard let response = response else {
                self.delegate?.showAlert(withTitle: "Falha na conexão", andMessage: "Não foi possível comunicar com o servidor, tente novamente mais tarde.")
                return
            }
            
            DispatchQueue.main.async {
                switch response.statusCode {
                case 200:
                    DispatchQueue.main.async {
                        guard let data = data else { return }
                        self.limitPage = data.totalPages
                        self.arrayMoviesSave += data.results
                        self.arrayMovies += data.results
                        completionHandler(true)
                    }
                default:
                    completionHandler(false)
                    self.delegate?.showAlert(withTitle: "Alerta", andMessage: "Desculpa o transtorno, houve um erro inesperado.")
                }
            }
        })
    }
    
    public func loadMoreMovies(indexPath: IndexPath, completionHandler: @escaping (Bool) -> Void) {
        if indexPath.row == arrayMovies.count - 4, limitPage > pageRequest {
            pageRequest += 1
            requestMovies(completionHandler: {
                reloadCollectionView in
                completionHandler(reloadCollectionView)
            })
        }
    }
    
    public func getMovie(indexPath: IndexPath) -> Movie {
        return arrayMovies[indexPath.row]
    }
    
    public func search(searchText: String, completionHandler: @escaping (Bool) -> Void ) {
        guard !searchText.isEmpty else {
            arrayMovies = arrayMoviesSave
            completionHandler(true)
            return
        }
        arrayMovies = arrayMoviesSave.filter({ movie -> Bool in
            let movieName = movie.title
            return movieName.contains(searchText)
        })
        
        completionHandler(true)
    }
}
