import SwiftUI

struct PostsView: View {
    
    @StateObject private var viewModel = PostViewModel()
    
    var body: some View {
        NavigationView {
            List {
                    ForEach(viewModel.posts.indices, id: \.self) { index
                        in
                        NavigationLink(destination: PostsDetailView(postBody: viewModel.posts[index].body)){
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Text("Id :    ")
                                    .foregroundColor(.black)
                                    .bold()
                                
                                Text("\(viewModel.posts[index].id)")
                                    .foregroundColor(.gray)
                            }
                            
                            HStack {
                                Text("Title :")
                                    .foregroundColor(.black)
                                    .bold()
                                
                                Text(viewModel.posts[index].title)
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(height: 80)
                        .padding()
                    }
                }
            }
            .onAppear {
                viewModel.loadPosts()
            }
            .listStyle(.plain)
            .navigationTitle("Posts")
            .padding()
        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostsView()
    }
}
