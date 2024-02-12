import KsApi
import SwiftUI

private struct PaginationExampleProjectCell: View {
  let title: String
  var body: some View {
    Text(title)
      .padding(.all, 10)
  }
}

private struct PaginationExampleProjectList: View {
  @Binding var projectIdsAndTitles: [(Int, String)]
  @Binding var showProgressView: Bool
  @Binding var statusText: String

  let onRefresh: () -> Void
  let onDidShowProgressView: () -> Void

  var body: some View {
    HStack {
      Spacer()
      Text("👉 \(statusText)")
      Spacer()
    }
    .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
    .background(.yellow)
    List {
      ForEach(projectIdsAndTitles, id: \.0) {
        let title = $0.1
        PaginationExampleProjectCell(title: title)
      }
      if showProgressView {
        HStack {
          Spacer()
          Text("Loading 😉")
            .onAppear {
              onDidShowProgressView()
            }
          Spacer()
        }
        .background(.yellow)
      }
    }
    .refreshable {
      onRefresh()
    }
  }
}

public struct PaginationExampleView: View {
  @StateObject private var viewModel = PaginationExampleViewModel()

  public var body: some View {
    //Note that PaginationExampleProjectList is decoupled from the view model;
    //all the information it needs is passed in via bindings.
    //This makes it easy to write a preview!
    PaginationExampleProjectList(
      projectIdsAndTitles: $viewModel.projectIdsAndTitles,
      showProgressView: $viewModel.showProgressView,
      statusText: $viewModel.statusText,
      onRefresh: {
        viewModel.didRefresh()
      },
      onDidShowProgressView: {
        viewModel.didShowProgressView()
      }
    )
  }
}

#Preview {
  PaginationExampleProjectList(
    projectIdsAndTitles: .constant([
      (1, "Cool project one"),
      (2, "Cool project two"),
      (3, "Cool project three")
    ]),
    showProgressView: .constant(true),
    statusText: .constant("Example status text"),
    onRefresh: {}, onDidShowProgressView: {}
  )
}
