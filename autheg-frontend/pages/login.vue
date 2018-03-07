<template>
  <section class="container">
    <div v-if="error">{{error}}</div>
    <div v-if="$auth.state.loggedIn">
      Logged in as {{$auth.state.user.email}}
      <button @click="logout">Log out</button>
      <p><router-link to="/">Home</router-link></p>
    </div>
    <div v-else>
      <input v-model="email" placeholder="Email">
      <input v-model="password" type="password" placeholder="Password">
      <button @click="login">Log in</button>
    </div>
  </section>
</template>

<script>
export default {
  data () {
    return {
      email: '',
      password: '',
      error: null
    }
  },
  methods: {
    login: function () {
      this.$auth.login({
        data: {
          user: {
            email: this.email,
            password: this.password
          }
        }
      }).catch(e => {this.error = e + ''})
    },
    logout: function () {
      this.$auth.logout().catch(e => {this.error = e + ''})
    }
  }
}
</script>
