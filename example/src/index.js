import * as Counter from '../output/Counter.Main'
import { unsafePerformEffect } from '../output/Effect.Unsafe'

function main() {
  const element = document.getElementById('root')

  unsafePerformEffect(Counter.main(element))
}

main()
