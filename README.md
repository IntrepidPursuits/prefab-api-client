# APIClient

[![Build Status](https://ci.intrepid.io/buildStatus/icon?job=api-client-ios)](https://ci.intrepid.io/job/api-client-ios/)
[![Coverage](http://ci.intrepid.io:9913/jenkins/cobertura/api-client-ios/)](https://ci.intrepid.io/job/api-client-ios/cobertura/)

The purpose of this library is to provide a pre-fabricated solution for the
networking layer of an iOS app.
___
# Table of Contents

1. [Installation](#installation)
    1. [Cocoapods](#cocoapods)
1. [Architecture](#architecture)
    1. [APIClient](#api-client)
    1. [Request](#request)
    1. [Third Party Libraries](#third-party-libraries)
1. [History](#history)

___

# Installation
## CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate APIClient into your Xcode project using CocoaPods, specify it in your `Podfile` (note: APIClient has not yet been added to a specs repository, so it must be referenced by either Github URL or local path):

```ruby
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'APIClient', :git => 'https://github.com/IntrepidPursuits/prefab-api-client.git'
end
```


Then, run the following command:

```bash
$ pod install
```
___

# Architecture
## APIClient
The main component of the library that is responsible for sending requests, handling response data and, optionally, mapping successful response data to expected object types. `APIClient` wraps an instance of `URLSession`, and provides a single function for executing a data task with a `URLRequest`. This core function parses response data to determine success or failure, and returns raw data for the success case and an appropriate `Error` for failure.

A `Genome`-specific subspec is also available, adding mapping capabilities to the client object. Additional functions extend upon the core implementation of `sendRequest()` and include a final mapping step prior to completion, where an attempt is made to map response data to the expected type. This type can be a single `MappableObject`, and array of `MappableObject`s, or `Void`.

## Request
The library also provides an interface for a request builder object, where application-specific endpoints will be implemented. This interface, which takes the form of a protocol called `Request`, exposes the various components of a `URLRequest` object, including URL, HTTP method, header values and body data. An extension of `Request` also implements a factory method for creating a `URLRequest` object based on the provided component values.

Usage of the protocol is left entirely up to the user, and possible implementations are widely varied. One potential pattern would be to use an `enum` type that conforms to `Request`, with cases representing individual endpoints, similar to the [AlamoFire Router pattern](https://github.com/Alamofire/Alamofire#routing-requests).

## Authentication
`APIClient` provides an out-of-the-box solution for handling expired/invalid tokens for authenticated requests. The `AuthTokenRefresher` class is responsible for handling these failed requests and has the ability sign in, refresh the token, configure the original request with the new token, and retry that request. Several protocols must be adopted by types in the user's application in order to enable token refresh functionality.
- `AuthClient`: Client object that exposes login function
- `CredentialProviding`: Object that stores saved user credentials and auth token, and also knows how to configure requests with that token

Additionally, the instance of `AuthTokenRefresher` must be created by the user with references to an `APIClient`, `AuthClient` and `CredentialProviding`. The appropriate instance of `APIClient` must then be configured with the resulting refresher object.

## Third Party Libraries
- Intrepid SwiftWisdom
- Genome (optional)
___

# History
Currently in development
