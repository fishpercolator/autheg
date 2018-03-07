<template>
  <section class="container">
    <div class="example" v-for="example in examples" :key="example.id" :style="`color:${example.colour}`">
      {{example.name}}
    </div>
    <p><router-link to="/login">Auth</router-link></p>
  </section>
</template>

<script>

export default {
  middleware: ['auth'],
  data () {
    return {
      examples: []
    }
  },
  methods: {
    async updateExamples() {
      this.examples = await this.$axios.$get('/examples')
    }
  },
  mounted () {
    this.updateExamples()
  }
}
</script>

<style>
.example {
  margin: 0.5em;
  padding: 0.5em;
  border: 1px solid currentColor;
}
</style>
