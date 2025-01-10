import Foundation

// MARK: - PostViewModel
class PostViewModel: ObservableObject {
    let urlStr = "https://jsonplaceholder.typicode.com/posts"
    @Published var posts: [Post] = []
    @Published var errorMessage: String? = nil
    
    func loadPosts() {
        NetworkManager.shared.fetchData(urlString: urlStr, model: [Post].self) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let posts):
                    self?.posts = posts
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
