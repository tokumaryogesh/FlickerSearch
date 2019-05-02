FlickSearch is image  searching app relying on flickr platform API's. The project is developed using Xcode 10.2 with Swift version 5. The project is entirely developed from scratch and some tradeoffs being made due to time constriants.  

Major components: 

Networking: Entire module is being developed to handle the server interaction. There is a BaseService class which act as helper to perform api calls. Based on the BaseService class every view controller should define its own service class to make things more maintainable. Each service have encodable parameters which gets passed whith service in case we need customization with every request.

URLSession is used to communicate to server and entire logic is defined in DataLoader class. The class is resposible for creating URLSessionTask and executing them.

Once the result is obtained the result get parsed using Decodable protocol. The service class associated with view controller will provided the type for decoding of result. BaseService class will do the decoding and return the result to caller via completion handler.

For downloading the images i had used operation queue so that that the priority of operations can be changed forvisible and non visible cells. The priority of the images in visible area is high and the other images outside the visible are is low so that the user can view the visible cell images on priority and gets a feeling that app is quite resposive. The class reposible for this optimisation is ImageDownloadManager.


SearchViewController: The view controller is reposible for dsplaying the images obtained from Api. Collection view is used to  display the result. The number of items displayed horizontally can be changed from Constant file. The view controller is having SearchViewModel which provide callback of different events to view controllers. SearchViewModel is responsible for getting data and giving the callback to viewcontroller once things are done.


Caching: In memory caching is done using NSCache and its configuration can be changed from contants like max no of items in cache, cache size, etc. DIsk cache is not done due to time contraint.

Messaging: In case of error or Api failure user is shown the message on searchviewcontroller with image.


TradeOffs:
* Disk caching needs to be done, currently in memory caching is done.
