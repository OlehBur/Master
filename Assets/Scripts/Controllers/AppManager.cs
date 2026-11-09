using VContainer;
using VContainer.Unity;

public class AppManager : IStartable {
    private readonly IDepthPresentationService _depthPresentationService;


    [Inject]
    public AppManager(IDepthPresentationService depthPresentationService) {
        _depthPresentationService = depthPresentationService;
    }

    void IStartable.Start() {
        _depthPresentationService.StartPresentation();
    }
}
