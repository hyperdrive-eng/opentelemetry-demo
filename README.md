<!-- markdownlint-disable-next-line -->
# <img src="https://avatars.githubusercontent.com/u/203325279?s=200&v=4" alt="Hyperdrive logo" width="45"> Microservices Debugging Playground

## Welcome to the Debugging Playground

This repository contains a mock online shop, made up of microservices. 

Our goals is to provide a realistic example of a distributed system that can be used to test and demo our debugging tool.

## Quick start

Prerequisites:

- Docker
- Docker Compose v2.0.0+
- 6 GB of RAM for the application

Start the demo: 

```sh
docker compose up --force-recreate --remove-orphans --detach
```

Source: https://opentelemetry.io/docs/demo/docker-deployment/

## Links

Once the images are built and containers are started you can access:

| Title | URL |
|-------|-----|
| Web store | http://localhost:8080/ |
| Grafana | http://localhost:8080/grafana/ |
| Load Generator UI | http://localhost:8080/loadgen/ |
| Jaeger UI | http://localhost:8080/jaeger/ui/ |
| Tracetest UI | http://localhost:11633/ |
| Flagd configurator UI | http://localhost:8080/feature |

Source: [Docker deployment][docker-deployment]

## Documentation

The OpenTelemetry Demo is composed of microservices written in different
programming languages that talk to each other over gRPC and HTTP; and a load
generator which uses [Locust](https://locust.io/) to fake user traffic.

| Service                               | Language      | Description                                                                                                                          |
| ------------------------------------- | ------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| [accounting](accounting/)             | .NET          | Processes incoming orders and count the sum of all orders (mock/).                                                                   |
| [ad](ad/)                             | Java          | Provides text ads based on given context words.                                                                                      |
| [cart](cart/)                         | .NET          | Stores the items in the user's shopping cart in Valkey and retrieves it.                                                             |
| [checkout](checkout/)                 | Go            | Retrieves user cart, prepares order and orchestrates the payment, shipping and the email notification.                               |
| [currency](currency/)                 | C++           | Converts one money amount to another currency. Uses real values fetched from European Central Bank. It's the highest QPS service.    |
| [email](email/)                       | Ruby          | Sends users an order confirmation email (mock/).                                                                                     |
| [fraud-detection](fraud-detection/)   | Kotlin        | Analyzes incoming orders and detects fraud attempts (mock/).                                                                         |
| [frontend](frontend/)                 | TypeScript    | Exposes an HTTP server to serve the website. Does not require sign up / login and generates session IDs for all users automatically. |
| [load-generator](load-generator/)     | Python/Locust | Continuously sends requests imitating realistic user shopping flows to the frontend.                                                 |
| [payment](payment/)                   | JavaScript    | Charges the given credit card info (mock/) with the given amount and returns a transaction ID.                                       |
| [product-catalog](product-catalog/)   | Go            | Provides the list of products from a JSON file and ability to search products and get individual products.                           |
| [quote](quote/)                       | PHP           | Calculates the shipping costs, based on the number of items to be shipped.                                                           |
| [recommendation](recommendation/)     | Python        | Recommends other products based on what's given in the cart.                                                                         |
| [shipping](shipping/)                 | Rust          | Gives shipping cost estimates based on the shopping cart. Ships items to the given address (mock/).                                  |
| [react-native-app](react-native-app/) | TypeScript    | React Native mobile application that provides a UI on top of the shopping services.                                                  |

Source: [Services][services]

```mermaid
graph TD
subgraph Service Diagram
accounting(Accounting):::dotnet
ad(Ad):::java
cache[(Cache<br/>&#40Valkey&#41)]
cart(Cart):::dotnet
checkout(Checkout):::golang
currency(Currency):::cpp
email(Email):::ruby
flagd(Flagd):::golang
flagd-ui(Flagd-ui):::typescript
fraud-detection(Fraud Detection):::kotlin
frontend(Frontend):::typescript
frontend-proxy(Frontend Proxy <br/>&#40Envoy&#41):::cpp
image-provider(Image Provider <br/>&#40nginx&#41):::cpp
load-generator([Load Generator]):::python
payment(Payment):::javascript
product-catalog(Product Catalog):::golang
quote(Quote):::php
recommendation(Recommendation):::python
shipping(Shipping):::rust
queue[(queue<br/>&#40Kafka&#41)]:::java
react-native-app(React Native App):::typescript

ad ---->|gRPC| flagd

checkout -->|gRPC| cart
checkout --->|TCP| queue
cart --> cache
cart -->|gRPC| flagd

checkout -->|gRPC| shipping
checkout -->|gRPC| payment
checkout --->|HTTP| email
checkout -->|gRPC| currency
checkout -->|gRPC| product-catalog

fraud-detection -->|gRPC| flagd

frontend -->|gRPC| ad
frontend -->|gRPC| cart
frontend -->|gRPC| checkout
frontend ---->|gRPC| currency
frontend ---->|gRPC| recommendation
frontend -->|gRPC| product-catalog

frontend-proxy -->|gRPC| flagd
frontend-proxy -->|HTTP| frontend
frontend-proxy -->|HTTP| flagd-ui
frontend-proxy -->|HTTP| image-provider

Internet -->|HTTP| frontend-proxy

load-generator -->|HTTP| frontend-proxy

payment -->|gRPC| flagd

queue -->|TCP| accounting
queue -->|TCP| fraud-detection

recommendation -->|gRPC| product-catalog
recommendation -->|gRPC| flagd

shipping -->|HTTP| quote

react-native-app -->|HTTP| frontend-proxy
end

classDef dotnet fill:#178600,color:white;
classDef cpp fill:#f34b7d,color:white;
classDef golang fill:#00add8,color:black;
classDef java fill:#b07219,color:white;
classDef javascript fill:#f1e05a,color:black;
classDef kotlin fill:#560ba1,color:white;
classDef php fill:#4f5d95,color:white;
classDef python fill:#3572A5,color:white;
classDef ruby fill:#701516,color:white;
classDef rust fill:#dea584,color:black;
classDef typescript fill:#e98516,color:black;
```

```mermaid
graph TD
subgraph Service Legend
  dotnetsvc(.NET):::dotnet
  cppsvc(C++):::cpp
  golangsvc(Go):::golang
  javasvc(Java):::java
  javascriptsvc(JavaScript):::javascript
  kotlinsvc(Kotlin):::kotlin
  phpsvc(PHP):::php
  pythonsvc(Python):::python
  rubysvc(Ruby):::ruby
  rustsvc(Rust):::rust
  typescriptsvc(TypeScript):::typescript
end

classDef dotnet fill:#178600,color:white;
classDef cpp fill:#f34b7d,color:white;
classDef golang fill:#00add8,color:black;
classDef java fill:#b07219,color:white;
classDef javascript fill:#f1e05a,color:black;
classDef kotlin fill:#560ba1,color:white;
classDef php fill:#4f5d95,color:white;
classDef python fill:#3572A5,color:white;
classDef ruby fill:#701516,color:white;
classDef rust fill:#dea584,color:black;
classDef typescript fill:#e98516,color:black;
```

Source: [Architecture][architecture]

[docs]: https://opentelemetry.io/docs/demo/
[services]: https://opentelemetry.io/docs/demo/services/
[docker-deployment]: https://opentelemetry.io/docs/demo/docker-deployment/
[architecture]: https://opentelemetry.io/docs/demo/architecture/