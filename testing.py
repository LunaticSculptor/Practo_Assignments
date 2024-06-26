import sentry_sdk

# Initialize Sentry
sentry_sdk.init(
    dsn="https://553455a0dc15f3cad9e4647bcc6034e7@o4507497332998144.ingest.us.sentry.io/4507497366814720",
    # Set traces_sample_rate to 1.0 to capture 100%
    # of transactions for performance monitoring.
    traces_sample_rate=1.0,
    # Set profiles_sample_rate to 1.0 to profile 100%
    # of sampled transactions.
    # We recommend adjusting this value in production.
    profiles_sample_rate=1.0,
)

def main():
    try:
        # This will cause a division by zero error
        1 / 0
    except Exception as e:
        # Capture the exception and send it to Sentry
        sentry_sdk.capture_exception(e)
        print("Exception captured and sent to Sentry:", e)

if __name__ == "__main__":
    main()
