
import SwiftUI

struct PostsDetailView: View {
     var postBody : String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20){
            Text("Details")
                .bold()
            
            Text("\(postBody)")
                .foregroundColor(.gray)
        }
        .padding()
        
        Spacer()
    }
    
}

struct PostsDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PostsDetailView(postBody: "hi")
    }
}
