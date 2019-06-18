## Combine

A basic implementation of Apple's Combine framework.

Most operators have been implemented (may with errors).

Publisher Operators implementation:

- [x] receiveOn
- [x] subscribeOn
- [x] map
- [x] tryMap
- [x] flatMap
- [x] mapError
- [x] replaceNil
- [x] scan
- [x] tryScan
- [x] setFailureType
- [x] filter
- [x] tryFilter
- [x] compactMap
- [x] tryCompactMap
- [x] removeDuplicates
- [x] tryRemoveDuplicates
- [x] replaceEmpty
- [x] replaceError
- [x] collect
- [x] ignoreOutput
- [x] reduce
- [x] tryReduce
- [x] count
- [x] max
- [x] tryMax
- [x] min
- [x] tryMin
- [x] contians
- [x] tryContians
- [x] allSatisfy
- [x] tryAllSatisfy
- [x] drop
- [ ] dropFirst
- [ ] tryDrop
- [ ] append
- [ ] prepend
- [ ] prefix
- [ ] tryPrefix
- [ ] first
- [ ] tryFirst
- [ ] last
- [ ] tryLast
- [ ] output
- [x] combineLatest
- [x] tryCombineLatest
- [ ] merge
- [ ] zip
- [ ] assertNoFailure
- [ ] catch
- [ ] retry
- [ ] switchToLatest
- [x] measureInterval
- [ ] debounce
- [ ] delay
- [ ] throttle
- [ ] timeout
- [x] share
- [ ] multicast
- [ ] breakpoint
- [ ] breakpointOnError
- [ ] handleEvents
- [ ] assign
- [ ] buffer
- [x] eraseToAnyPublisher
- [ ] makeConnectable
- [ ] prefix
- [x] print
- [x] sink

Publishers implementation:
- [x] Empty
- [x] Fail
- [x] Just
- [x] Once
- [x] Optional
- [x] Sequence
- [x] Deferred
