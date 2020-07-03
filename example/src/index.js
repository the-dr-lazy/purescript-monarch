import * as Counter from '../output/Counter.Main'

function main() {
  const element = document.getElementById('root')

  unsafePerformcEffect(Counter.main(element))
}

main()
