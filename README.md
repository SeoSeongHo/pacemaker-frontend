# pacemaker-frontend
GPS-based running match matching service (Mobile Computing, 2021 Fall)

compete in real time with the actual moving distance.

## Features
- ReactorKit
- RxSwift
- Alamofire
- Core location
- Map Kit
- Auto layout with SnapKit

## Architecture
- Uni-directional hierarchy
- ViewController -> Reactor -> UseCases -> Managers

## Getting started
Using cocoapods to manage dependencies.
```
$ pod install
```
When dependency installation is done, open `pacemaker-frontend.xcworkspace` with xcode 13.1
```
$ open pacemaker-frontend.xcworkspace
```
Select pacemaker-frontend target and device, and run.


- [proposal.pdf](https://github.com/SeoSeongHo/pacemaker-frontend/blob/main/proposal.pdf)
