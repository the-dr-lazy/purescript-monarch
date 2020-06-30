//
// Primitives
//
type Unit = void
type Int = number
type Lazy<a> = () => a

//
// Data Types
//
type Effect<a> = Lazy<a>
