//
//  TrackController.swift
//  songsurprise
//
//  Created by resoul on 12.09.2024.
//

import UIKit

class TrackController: UIViewController {
    
    private var genre: GenreModel
    private var tracks: [TrackModel] = []
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.register(cell: TrackViewCell.self)
        view.delegate = self
        view.dataSource = self
        
        return view
    }()
    
    init(genre: GenreModel) {
        self.genre = genre
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = genre.name
        
        view.addSubview(tableView)
        tableView.constraints(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        
        Task {
            tracks = try await supabase.from("songs").select()
                .eq("genre_id", value: genre.id).execute().value
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TrackController: TableViewProvider {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: TrackViewCell.self)
        cell.accessoryType = .disclosureIndicator
        cell.configure(tracks[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        present(PlayerController(index: indexPath.row, tracks: tracks), animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
