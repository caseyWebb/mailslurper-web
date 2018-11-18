declare module '*Main.elm' {
  type ElmApplication = {}

  export const Elm: {
    Main: {
      init(): ElmApplication
    }
  }
}
