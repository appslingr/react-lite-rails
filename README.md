# react_lite-rails

This is a quickly made fork of the gem: [react-rails](https://github.com/reactjs/react-rails) that replaces Facebook's 
React JS library with [react-lite](https://github.com/Lucifier129/react-lite). 
There are no add-ons provided except for [immutable-assign](https://github.com/engineforce/ImmutableAssign) which serves
as a non drop-in replacement for `React.addons.update` in order to avoid using Facebook's invariant library.
## Development

- Update React assets with `rake react:update`
